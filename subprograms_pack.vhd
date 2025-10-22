library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package subprograms_pack is
	function n_to_segment(n : natural) return std_logic_vector;
end package;

-- enkel funksjon for å gjøre om et heltall til korresponderende 7-seg verdi
package body subprograms_pack is
	function n_to_segment(n : natural) return std_logic_vector is
		variable hex : std_logic_vector(7 downto 0);
	begin
		case n is
			when 0 => hex := "11000000";
			when 1 => hex := "11111001";
			when 2 => hex := "10100100";
			when 3 => hex := "10110000";
			when 4 => hex := "10011001";
			when 5 => hex := "10010010";
			when 6 => hex := "10000010";
			when 7 => hex := "11111000";
			when 8 => hex := "10000000";
			when 9 => hex := "10010000";
			when others => hex := (others => '0');
		end case;
		return hex;
	end function;
end package body;
