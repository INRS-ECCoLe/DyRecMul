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
--  Edge Computing, Communication and Learning Lab (ECCoLe) 
--
--  Author: Shervin Vakili, INRS University
--  Project: Reconfig MAC 
--  Creation Date: 2023-05-10
--  Description: UINT12 DyRecMul multiplier top module with float(0, 3, 5)
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

entity DyRecMul_UINT12 is
    generic(LENGTH : integer:= 12;
            INOUT_BUF_EN : boolean:= True; -- Set to True for timing measurment, set to False for area utilization measurments
            PING_PONG_EN : boolean:= True);
    Port ( m_i : in STD_LOGIC_VECTOR (LENGTH-1 downto 0);  -- Mult input 1
           clk, rst : in STD_LOGIC;
           CDI_i : in STD_LOGIC;
           ping_pong_sel_i : in STD_LOGIC;
           wr_conf_i : in STD_LOGIC;    
          
           result_o : out STD_LOGIC_VECTOR (LENGTH-1 downto 0)
    );
end DyRecMul_UINT12;

architecture Behavioral of DyRecMul_UINT12 is
    signal mult_result : STD_LOGIC_VECTOR (4 downto 0);
    signal mult_result_s : STD_LOGIC_VECTOR (4 downto 0);
    signal mult_result_p : STD_LOGIC_VECTOR (4 downto 0);
    signal decoded_mult_res : STD_LOGIC_VECTOR (LENGTH-1 downto 0);
    signal wr_conf_s : STD_LOGIC;
    signal wr_conf_p : STD_LOGIC;
    signal c_sign : STD_LOGIC; -- sign bit of the coeficient
    signal mantissa : STD_LOGIC_VECTOR (4 downto 0);
    signal exponent : STD_LOGIC_VECTOR (2 downto 0);
    signal m_buf : STD_LOGIC_VECTOR (LENGTH-1 downto 0);
    
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

    INOUT_BUFS: if INOUT_BUF_EN = True generate
        process(clk)
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    result_o <= (others => '0');
                    c_sign  <= '0';
                else
                    if wr_conf_i = '1' then
                        c_sign <= CDI_i;
                    end if;
                    m_buf <= m_i;
                    result_o <= decoded_mult_res;
                end if;
            end if;
        end process;
    end generate;
    
    NO_INOUT_BUFS: if INOUT_BUF_EN = False generate
    process(clk)
    begin
        if rising_edge(clk) then     
            if wr_conf_i = '1' then
                c_sign <= CDI_i;
            end if; 
         end if;
    end process;
    m_buf <= m_i;
    result_o <= decoded_mult_res;   
    end generate;
    
    -- Encoder (Fixed-to-Float convert)
    exponent <= "111" when m_buf(11)='1'  else
                "110" when m_buf(11 downto 10)="01"  else
                "101" when m_buf(11 downto 9)="001" else

                "100" when m_buf(11 downto 8)="0001" else
                "011" when m_buf(11 downto 7)="00001" else
                "010" when m_buf(11 downto 6)="000001" else
                "001" when m_buf(11 downto 5)="0000001" else
                "000";
                 
    mantissa <= m_buf(11 downto 7) when exponent = "111" else
                m_buf(10 downto 6) when exponent = "110" else
                m_buf(9 downto 5) when exponent  = "101" else
                m_buf(8 downto 4) when exponent  = "100" else
                m_buf(7 downto 3) when exponent  = "011" else
                m_buf(6 downto 2) when exponent  = "010" else
                m_buf(5 downto 1) when exponent  = "001" else
                m_buf(4 downto 0);

    
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
     decoded_mult_res <=    (     mult_result & "0000000") when exponent = "111" else
                            ('0' & mult_result & "000000") when exponent = "110" else
                            ("00" & mult_result & "00000") when exponent = "101" else
                            ("000" & mult_result & "0000") when exponent = "100" else
                            ("0000" & mult_result & "000") when exponent = "011" else
                            ("00000" & mult_result & "00") when exponent = "010" else
                            ("000000" & mult_result & "0") when exponent = "001" else
                            ("0000000" & mult_result     );
   

end Behavioral;
