---------------------------------------------------------------------------------------------------
--                __________
--    ______     /   ________      _          ______
--   |  ____|   /   /   ______    | |        |  ____|
--   | |       /   /   /      \   | |        | |
--   | |____  /   /   /        \  | |        | |____
--   |  ____| \   \   \        /  | |        |  ____|   
--   | |       \   \   \______/   | |        | |
--   | |____    \   \________     | |_____   | |____
--   |______|    \ _________      |_______|  |______|
--
--  Edge Computing, Communication and Learning Lab (ECCoLE) 
--
--  Author: Shervin Vakili, INRS University
--  Project: Reconfig MAC 
--  Creation Date: 2023-05-10
--  Description: Multiply and accumulate top module
------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all; 
Library UNISIM;
use UNISIM.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Reconfig_MAC_top is
    generic(LENGTH : integer:= 8;
            PING_PONG_EN : boolean:= False);
    Port ( m_i : in STD_LOGIC_VECTOR (LENGTH-1 downto 0);  -- Mult input 1
           a_i: in STD_LOGIC_VECTOR (LENGTH-1 downto 0);    -- Add input
           clk, rst : in STD_LOGIC;
           CDI_i : in STD_LOGIC;
           ping_pong_sel_i : in STD_LOGIC;
           wr_conf_i : in STD_LOGIC;    
          
           result_o : out STD_LOGIC_VECTOR (LENGTH-1 downto 0)
    );
end Reconfig_MAC_top;

architecture Behavioral of Reconfig_MAC_top is
    signal mult_result : STD_LOGIC_VECTOR (4 downto 0);
    signal mult_result_s : STD_LOGIC_VECTOR (4 downto 0);
    signal mult_result_p : STD_LOGIC_VECTOR (4 downto 0);
    signal decoded_mult_res : STD_LOGIC_VECTOR (LENGTH-2 downto 0);
    signal wr_conf_s : STD_LOGIC;
    signal wr_conf_p : STD_LOGIC;
    signal c_sign : STD_LOGIC; -- sign bit of the coeficient
    signal mantissa : STD_LOGIC_VECTOR (4 downto 0);
    signal mantissa_t : STD_LOGIC_VECTOR (4 downto 0);
    signal exponent : STD_LOGIC_VECTOR (1 downto 0);
    signal m_buf : STD_LOGIC_VECTOR (LENGTH-1 downto 0);
    signal a_buf : STD_LOGIC_VECTOR (LENGTH-1 downto 0);
    
    component reconfig_mult is
      Port (CDI_i   : in std_logic;
            wr_conf : in std_logic;
            data_i  : in std_logic_vector(4 downto 0);
            clk     : in std_logic;
            data_o  : out std_logic_vector(4 downto 0)
       );
    end component;
begin

    wr_conf_s <= '0' when PING_PONG_EN = False else (wr_conf_i and ping_pong_sel_i);
    wr_conf_p <= wr_conf_i when PING_PONG_EN = False else (wr_conf_i and not ping_pong_sel_i);

 process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                result_o <= (others => '0');
                c_sign  <= '0';
            else
                m_buf <= m_i;
                a_buf <= a_i;
                if (m_buf(7) xor c_sign) = '0' then
                    result_o <= a_buf + decoded_mult_res;
                else
                    result_o <= a_buf - decoded_mult_res;
                end if;
                if wr_conf_i = '1' then
                    c_sign <= CDI_i;
                end if; 
             end if;
        end if;
    end process;
    
    -- Encoder (Fixed-to-Float convert)
    exponent <= "10" when m_buf(7 downto 6)="01" or  m_buf(7 downto 6)="10" else
                "01" when m_buf(7 downto 5)="001" or  m_buf(7 downto 5)="110" else
                "00";
                 
    mantissa_t <= m_buf(6 downto 2) when exponent = "10" else
                m_buf(5 downto 1) when exponent = "01" else
                m_buf(4 downto 0);
    mantissa <= mantissa_t when m_buf(7) = '0' else (not mantissa_t + 1);

--    mantissa(0) <=      m_buf(2) when exponent = "10" and m_buf(7)='0' else
--                    not m_buf(2) when exponent = "10" and m_buf(7)='1' else
--                        m_buf(1) when exponent = "01" and m_buf(7)='0' else
--                    not m_buf(1) when exponent = "01" and m_buf(7)='1' else
--                        m_buf(0) when exponent = "00" and m_buf(7)='0' else
--                    not m_buf(0);

--    mantissa(1) <=      m_buf(3) when exponent = "10" and m_buf(7)='0' else
--                    not m_buf(3) when exponent = "10" and m_buf(7)='1' else
--                        m_buf(2) when exponent = "01" and m_buf(7)='0' else
--                    not m_buf(2) when exponent = "01" and m_buf(7)='1' else
--                        m_buf(1) when exponent = "00" and m_buf(7)='0' else
--                    not m_buf(1);

--    mantissa(2) <=  m_buf(4) xor m_buf(7) when exponent = "10" else
--                    m_buf(3) xor m_buf(7) when exponent = "01" else
--                    m_buf(2) xor m_buf(7);

--    mantissa(3) <=  m_buf(5) xor m_buf(7) when exponent = "10" else
--                    m_buf(4) xor m_buf(7) when exponent = "01" else
--                    m_buf(3) xor m_buf(7);

--    mantissa(4) <=  m_buf(6) xor m_buf(7) when exponent = "10" else
--                    m_buf(5) xor m_buf(7) when exponent = "01" else
--                    m_buf(4) xor m_buf(7);

--    LUT6_inst0 : LUT6
--        generic map (
--            INIT => X"000000AB50000000") -- Specify LUT Contents
--        port map (
--            O => mantissa(0),  -- LUT general output
--            I0 => m_buf(2),   -- LUT input
--            I1 => m_buf(2),   -- LUT input
--            I2 => m_buf(2),   -- LUT input
--            I3 => m_buf(2),   -- LUT input
--            I4 => exponent(1),   -- LUT input
--            I5 => exponent(0)    -- LUT input
--        );

--    LUT6_inst1 : LUT6
--        generic map (
--            INIT => X"0000000000458000") -- Specify LUT Contents
--        port map (
--            O => mantissa(1),  -- LUT general output
--            I0 => m_buf(2),   -- LUT input
--            I1 => m_buf(2),   -- LUT input
--            I2 => m_buf(2),   -- LUT input
--            I3 => m_buf(2),   -- LUT input
--            I4 => exponent(1),   -- LUT input
--            I5 => exponent(0)    -- LUT input
--        );

--    LUT6_inst2 : LUT6
--        generic map (
--            INIT => X"0000230000458000") -- Specify LUT Contents
--        port map (
--            O => mantissa(2),  -- LUT general output
--            I0 => m_buf(2),   -- LUT input
--            I1 => m_buf(2),   -- LUT input
--            I2 => m_buf(2),   -- LUT input
--            I3 => m_buf(2),   -- LUT input
--            I4 => exponent(1),   -- LUT input
--            I5 => exponent(0)    -- LUT input
--        );
--    LUT6_inst3 : LUT6
--        generic map (
--            INIT => X"0000230000458BBB") -- Specify LUT Contents
--        port map (
--            O => mantissa(3),  -- LUT general output
--            I0 => m_buf(5),   -- LUT input
--            I1 => m_buf(4),   -- LUT input
--            I2 => m_buf(3),   -- LUT input
--            I3 => m_buf(7),   -- LUT input
--            I4 => exponent(1),   -- LUT input
--            I5 => exponent(0)    -- LUT input
--        );

--    LUT6_inst4 : LUT6
--        generic map (
--            INIT => X"0000230000458AAA") -- Specify LUT Contents
--        port map (
--            O => mantissa(4),  -- LUT general output
--            I0 => m_buf(6),   -- LUT input
--            I1 => m_buf(5),   -- LUT input
--            I2 => m_buf(4),   -- LUT input
--            I3 => m_buf(7),   -- LUT input
--            I4 => exponent(1),   -- LUT input
--            I5 => exponent(0)    -- LUT input
--        );
    
    -- Reconfigurable Multiplier
    RECONF_MULT: reconfig_mult 
      port map( CDI_i   => c_sign,
                wr_conf => wr_conf_p,
                data_i  => mantissa,
                clk     => clk,
                data_o  => mult_result_p
       );
    
    -- Ping-pong mechanism for the multiplier
    PING_PONG: if PING_PONG_EN = True generate
        RECONF_MULT_S: reconfig_mult -- second multiplier in ping pong mechanism
              port map( CDI_i   => c_sign,
                        wr_conf => wr_conf_s,
                        data_i  => mantissa,
                        clk     => clk,
                        data_o  => mult_result_s
               );
         mult_result <= mult_result_s when ping_pong_sel_i= '1' else mult_result_p;
     end generate;
     
     NO_PING_PONG: if PING_PONG_EN = False generate
        mult_result <= mult_result_p;
     end generate;
     
     -- Decoder (Float-to-Fixed convert)
     decoded_mult_res <=    (mult_result & "00") when exponent = "10" else
                            ('0' & mult_result & "0") when exponent = "01" else
                            ("00" & mult_result);
   

end Behavioral;
