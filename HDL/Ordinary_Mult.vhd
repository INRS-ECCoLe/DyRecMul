----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/27/2023 02:55:01 AM
-- Design Name: 
-- Module Name: ord_mult - Behavioral
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
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ord_mult is
    generic(LENGTH : integer:= 7);
    Port ( a : in STD_LOGIC_VECTOR (LENGTH-1 downto 0);  -- Mult input 1
           b : in STD_LOGIC_VECTOR (LENGTH-1 downto 0);    -- Mult input 2
           add_i: in STD_LOGIC_VECTOR (LENGTH-1 downto 0);  -- Add input
           clk, rst : in STD_LOGIC;
           
           result_o : out STD_LOGIC_VECTOR (LENGTH-1 downto 0)
           );
end ord_mult;

architecture Behavioral of ord_mult is
    signal temp :  STD_LOGIC_VECTOR (2*LENGTH-1 downto 0);
    signal a_buf : STD_LOGIC_VECTOR (LENGTH-1 downto 0);
    signal b_buf : STD_LOGIC_VECTOR (LENGTH-1 downto 0);
    signal add_buf: STD_LOGIC_VECTOR (LENGTH-1 downto 0);  -- Add input
begin
    temp <= a_buf * b_buf;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                result_o <= (others => '0');
            else
                a_buf <= a;
                b_buf <= b;
                add_buf <= add_i;
                result_o <= add_buf + temp(2*LENGTH-1 downto LENGTH);
             end if;
        end if;
    end process;


end Behavioral;
