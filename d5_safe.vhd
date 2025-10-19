library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
  


entity d5_safe is
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;            			-- Key0
        incr_key : in  std_logic;            			-- Key1
        sw0      : in  std_logic;            			-- Open/close safe, SW0
        seg_sel  : in  std_logic_vector(1 downto 0);  -- Select 7-segment, SW1-SW2
        sw9      : in  std_logic;            			-- Show secret key, SW9
        open_led : out std_logic;            			-- LEDR0
        hex0     : out std_logic_vector(7 downto 0);  -- HEX0 7-segment
        hex1     : out std_logic_vector(7 downto 0);  -- HEX1 7-segment
        hex2     : out std_logic_vector(7 downto 0);  -- HEX2 7-segment
        hex3     : out std_logic_vector(7 downto 0)   -- HEX3 7-segment
    );
end entity d5_safe;


architecture RTL of d5_safe is

end architecture RTL;