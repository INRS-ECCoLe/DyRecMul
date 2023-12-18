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
--  Description: UINT8 DyRecMul multiplier top module
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

entity DyRecMul_UINT8 is
    generic(LENGTH : integer:= 8;
            INOUT_BUF_EN : boolean:= True; -- Set to True for timing measurment, set to False for area utilization measurments
            PING_PONG_EN : boolean:= False);
    Port ( m_i : in STD_LOGIC_VECTOR (LENGTH-1 downto 0);  -- Mult input 1
           clk, rst : in STD_LOGIC;
           CDI_i : in STD_LOGIC;
           ping_pong_sel_i : in STD_LOGIC;
           wr_conf_i : in STD_LOGIC;    
          
           result_o : out STD_LOGIC_VECTOR (LENGTH-1 downto 0)
    );
end DyRecMul_UINT8;

architecture Behavioral of DyRecMul_UINT8 is
    signal mult_result : STD_LOGIC_VECTOR (4 downto 0);
    signal mult_result_s : STD_LOGIC_VECTOR (4 downto 0);
    signal mult_result_p : STD_LOGIC_VECTOR (4 downto 0);
    signal decoded_mult_res : STD_LOGIC_VECTOR (LENGTH-1 downto 0);
    signal wr_conf_s : STD_LOGIC;
    signal wr_conf_p : STD_LOGIC;
    signal c_sign : STD_LOGIC; -- sign bit of the coeficient
    signal mantissa : STD_LOGIC_VECTOR (4 downto 0);
    signal exponent : STD_LOGIC_VECTOR (1 downto 0);
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
    exponent <= "11" when m_buf(7)='1'  else
                "10" when m_buf(7 downto 6)="01"  else
                "01" when m_buf(7 downto 5)="001" else
                "00";
                 
    mantissa <= m_buf(7 downto 3) when exponent = "11" else
                m_buf(6 downto 2) when exponent = "10" else
                m_buf(5 downto 1) when exponent = "01" else
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
     decoded_mult_res <=    (mult_result & "000") when exponent = "11" else
                            ('0' & mult_result & "00") when exponent = "10" else
                            ("00" & mult_result & '0') when exponent = "01" else
                            ("000" & mult_result);
   

end Behavioral;
