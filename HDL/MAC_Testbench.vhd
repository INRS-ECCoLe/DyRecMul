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
--  ECCoLe: Edge Computing, Communication and Learning Lab - INRS University
--
--  Author: Shervin Vakili
--  Project: Reconfigurable MAC 
--  Creation Date: 2023-04-31
--  Description: Testbench for reconfigurable MAC
------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MAC_Testbench is
--  Port ( );
end MAC_Testbench;

architecture Behavioral of MAC_Testbench is
    constant LENGTH : integer := 8;
    constant TEST_LENGTH        : integer := 4;
    constant clk_period : time := 10 ns;
    signal mult_op          : std_logic_vector (LENGTH-1 downto 0);
    signal add_op           : std_logic_vector (LENGTH-1 downto 0);  
    signal clk, rst         : STD_LOGIC;
    signal CDI              : STD_LOGIC;
    signal ping_pong_sel    : STD_LOGIC;
    signal wr_conf          : STD_LOGIC; 
    signal result           : std_logic_vector (LENGTH-1 downto 0);
    signal LUT_contents     : std_logic_vector(0 to 5 * 32);
    signal counter          : integer range 0 to 1000;
    signal test_counter     : integer;
    signal bit_cnt          : integer;
    type test_coef_vec_type is array (1 to TEST_LENGTH) of integer;
    constant test_coef_vec  : test_coef_vec_type := (61, 101, 180, 221); -- To store in reconfig LUTs
    constant test_mult_vec  : test_coef_vec_type := (12, 37, 68, 201); -- To be fed as mult input value

    component Reconfig_MAC_top is
        generic(LENGTH : integer:= 8;
                PING_PONG_EN : boolean:= True);
        Port ( m_i : in STD_LOGIC_VECTOR (LENGTH-1 downto 0);  -- Mult input 1
               a_i: in STD_LOGIC_VECTOR (LENGTH-1 downto 0);  -- Add input
               clk, rst : in STD_LOGIC;
               CDI_i : in STD_LOGIC;
               ping_pong_sel_i : in STD_LOGIC;
               wr_conf_i : in STD_LOGIC;    
              
               result_o : out STD_LOGIC_VECTOR (LENGTH-1 downto 0)
        );
    end component;

    impure function LUT_content_calc (coef : integer) return std_logic_vector is 			 
        variable LUT_contents       : std_logic_vector(0 to 5 * 32);
        variable coef_std_logic     : std_logic_vector(7 downto 0);
        variable temp               : std_logic_vector(12 downto 0);
        variable temp_result        : std_logic_vector(4 downto 0); 	
        variable abs_coef           : integer; 	  
    begin
        
        if coef < 0 then
            abs_coef := -coef;
            LUT_contents(5 * 32) := '1'; --sign bit
        else
            abs_coef := coef;
            LUT_contents(5 * 32) := '0'; --sign bit
        end if;

        coef_std_logic := conv_std_logic_vector(abs_coef, 8);
        for i in 0 to 31 loop   
            temp := coef_std_logic * conv_std_logic_vector(i, 5);
            if temp(7) = '1' then -- rounding
                temp_result := temp(12 downto 8) + 1;
            else
                temp_result := temp(12 downto 8);
            end if;
            for j in 0 to 4 loop
                LUT_contents(5*32 - j*32 - i - 1) := temp_result(j);
            end loop;
        end loop;
        return LUT_contents;
    end function;		

begin

    clk_process :process
		begin
			clk <= '0';
			wait for clk_period/2;  --for 0.5 ns signal is '0'.
			clk <= '1';
			wait for clk_period/2;  --for next 0.5 ns signal is '1'.
		end process;				
	rst <=  '1' , '0' after 4 * clk_period;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                LUT_contents <= LUT_content_calc(test_coef_vec(1));
                counter <= 0;
                wr_conf <= '0';
                test_counter <= 2;
            else
                if counter < 200 then
                    counter <= counter + 1;
                else
                    counter <= 0;
                    test_counter <= test_counter + 1;
                    LUT_contents <= LUT_content_calc(test_coef_vec(test_counter));
                end if;

                if counter < 160 then
                    CDI <= LUT_contents(counter);
                    wr_conf <= '1';
                else
                    CDI <= '0';
                    wr_conf <= '0';
                end if;
                    --bit_cnt <= bit_cnt + 1;
                if counter = 160 then
                    mult_op <= conv_std_logic_vector(test_mult_vec(1), 8);
                elsif counter = 170 then
                    mult_op <= conv_std_logic_vector(test_mult_vec(2), 8);
                elsif counter = 180 then
                    mult_op <= conv_std_logic_vector(test_mult_vec(3), 8);
                elsif counter = 190 then
                    mult_op <= conv_std_logic_vector(test_mult_vec(4), 8);
                end if;

            end if;
        end if;
    end process;

    ping_pong_sel <= '0';
    add_op <= conv_std_logic_vector(25,8);

    MAC_INST: Reconfig_MAC_top 
    generic map(    LENGTH => 8,
                    PING_PONG_EN => True)
    Port map(   m_i             => mult_op, -- Mult input 1
                a_i             => add_op, -- Add input
                clk             => clk,
                rst             => rst,
                CDI_i           => CDI,
                ping_pong_sel_i => ping_pong_sel,
                wr_conf_i       => wr_conf,   
          
                result_o        => result
    );


end Behavioral;
