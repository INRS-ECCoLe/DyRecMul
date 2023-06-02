----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2023 01:15:13 AM
-- Design Name: 
-- Module Name: test - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


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

entity Reconfig_MAC is
    generic(LENGTH : integer:= 8;
            PING_PONG_EN : boolean:= True);
    Port ( m1_i : in STD_LOGIC_VECTOR (LENGTH-1 downto 0);  -- Mult input 1
           --m2_i : in STD_LOGIC_VECTOR (LENGTH-1 downto 0);    -- Mult input 2
           a_i: in STD_LOGIC_VECTOR (LENGTH-1 downto 0);  -- Add input
           clk, rst : in STD_LOGIC;
           CDI_i : in STD_LOGIC;
           ping_pong_sel_i : in STD_LOGIC;
           wr_conf_i : in STD_LOGIC;    
          
           result_o : out STD_LOGIC_VECTOR (LENGTH-1 downto 0)
    );
end Reconfig_MAC;

architecture Behavioral of Reconfig_MAC is
    signal mult_result : STD_LOGIC_VECTOR (4 downto 0);
    signal mult_result_s : STD_LOGIC_VECTOR (4 downto 0);
    signal mult_result_p : STD_LOGIC_VECTOR (4 downto 0);
    signal decoded_mult_res : STD_LOGIC_VECTOR (LENGTH-1 downto 0);
    signal wr_conf_s : STD_LOGIC;
    signal wr_conf_p : STD_LOGIC;

    signal CDO_t : STD_LOGIC; 
    signal temp : STD_LOGIC_VECTOR (4 downto 0);
    signal acc : STD_LOGIC_VECTOR (4 downto 0);
    signal s : STD_LOGIC_VECTOR (2 downto 0);
    signal shifted_x : STD_LOGIC_VECTOR (4 downto 0);
    signal shift_cnt : STD_LOGIC_VECTOR (1 downto 0);
    
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
            else
                if m1_i(7) = '0' then
                    result_o <= a_i + decoded_mult_res;
                else
                    result_o <= a_i - decoded_mult_res;
                end if;
             end if;
        end if;
    end process;
                    
    shift_cnt <= "11" when m1_i(7 downto 6)="01" or  m1_i(7 downto 6)="10" else
                 "10" when m1_i(7 downto 5)="001" or  m1_i(7 downto 5)="110" else
                 "01" when m1_i(7 downto 4)="0001" or  m1_i(7 downto 4)="1110" else
                 "00";
                 
    shifted_x <=    m1_i(6 downto 2) when shift_cnt = "11" else
                    m1_i(5 downto 1) when shift_cnt = "10" else
                    m1_i(4 downto 0);
    
    RECONF_MULT: reconfig_mult 
      port map( CDI_i   => CDI_i,
                wr_conf => wr_conf_p,
                data_i  => shifted_x,
                clk     => clk,
                data_o  => mult_result_p
       );
       
    PING_PONG: if PING_PONG_EN = True generate
        RECONF_MULT_S: reconfig_mult -- second multiplier in ping pong mechanism
              port map( CDI_i   => CDI_i,
                        wr_conf => wr_conf_s,
                        data_i  => shifted_x,
                        clk     => clk,
                        data_o  => mult_result_s
               );
         mult_result <= mult_result_s when ping_pong_sel_i= '1' else mult_result_p;
     end generate;
     
     NO_PING_PONG: if PING_PONG_EN = False generate
        mult_result <= mult_result_p;
     end generate;
       
     decoded_mult_res <=    (mult_result & "000") when shift_cnt = "11" else
                            (mult_result(4) & mult_result & "00") when shift_cnt = "10" else
                            (mult_result(4) & mult_result(4) & mult_result & "0");
   

end Behavioral;
