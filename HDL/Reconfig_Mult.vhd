----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/24/2023 11:32:56 PM
-- Design Name: 
-- Module Name: reconfig_mult - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity reconfig_mult is
  Port (CDI_i   : in std_logic;
        wr_conf : in std_logic;
        data_i  : in std_logic_vector(4 downto 0);
        clk     : in std_logic;
        data_o  : out std_logic_vector(4 downto 0)
   );
end reconfig_mult;

architecture Behavioral of reconfig_mult is
    signal CDI: std_logic_vector(5 downto 0);
begin

    CDI(0) <= CDI_i;

    CFGLUTs: for ii in 0 to 4 generate
    
     CFGLUT5_inst1 : CFGLUT5
        generic map (
           INIT => X"2F356322")
        port map (
           CDO  => CDI(ii+1), -- Reconfiguration cascade output
           O5   => open,--O5_t,   -- 4-LUT output
           O6   => data_o(ii),   -- 5-LUT output
           CDI  => CDI(ii), -- Reconfiguration data input
           CE   => wr_conf,   -- Reconfiguration enable input
           CLK  => clk, -- Clock input
           I0   => data_i(0),   -- Logic data input
           I1   => data_i(1),   -- Logic data input
           I2   => data_i(2),   -- Logic data input
           I3   => data_i(3),   -- Logic data input
           I4   => data_i(4)    -- Logic data input
        );
    end generate;
    
end Behavioral;
