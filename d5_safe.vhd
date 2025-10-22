library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- importer subprograms_pack.vhd
library work;
use work.subprograms_pack.all;

entity d5_safe is
	generic (
		HEX_MAX: natural := 9; -- største hex-verdi
		DIGITS: natural := 4 -- antall siffer i kode
		);
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
	-- definer 7-segment datatype og sett til signal
	type hex_array_t is array (0 to DIGITS-1) of std_logic_vector(7 downto 0);
	signal hex_int : hex_array_t;

	-- bestem siffer-størrelse 0..9 i dette tilfellet
	subtype code_elem_t is natural range 0 to HEX_MAX;

	-- bestem array-størrelse til 4 sifre
	type code_t is array (0 to DIGITS-1) of code_elem_t;
	
	-- vises alltid på 7-seg displayet
	signal codes : code_t := (others => 0);
	
	-- mellomlagring for alle inntastede verdier for enkel sw9 og tilbake sjekk
	signal temp_codes: code_t := (others => 0);
	
	-- div
	constant SECRET : code_t := (4,3,2,1); -- hemmelig koden
	signal prev_incr : std_logic := '1'; -- hold styr på debounce
	signal d_id : natural range 0 to DIGITS-1; -- bestemmer siffer og display som justeres
	signal match : std_logic; -- sier i fra om riktig kode er oppgitt
	signal rst_open : std_logic := '1'; -- åpne/lukke safe
begin

-- n-til-segment-display transformajson
gen_hex : for i in codes'range generate
	hex_int(i) <= n_to_segment(codes(i));
end generate;

-- hack løsning for enkel reversering slik at 00 gir numerisk verdi 3
d_id <= (DIGITS-1)-to_integer(unsigned(seg_sel));

-- sekvensielle delen av systemet
P1 : process(clk, rst_n)
begin
	if rst_n = '0' then
		for i in codes'range loop
			temp_codes(i) <= 0; -- reset inntastet kode
		end loop;
		prev_incr <= '1'; -- sørger for at debounce fortsatt funker
		rst_open <= '1'; -- setter safe i åpen-tilstand ved rst
	elsif rising_edge(clk) then
		-- håndter lukking av safe
		if sw0 = '1' then
			rst_open <= '0';
		end if;
		-- håndter at tastetrykk kun oppdaterer ved stigende flanke
		if (incr_key = '0' and prev_incr = '1') then
			-- oppdater kodeverdi bestemt av seg_sel (digit-id-signalet)
			if temp_codes(d_id) = HEX_MAX then
				-- "wrap rundt" når maksimal hex-verdi er nådd
				temp_codes(d_id) <= 0;
			else
				-- oppdater temp kode-array
				temp_codes(d_id) <= temp_codes(d_id) + 1;
			end if;
		end if;
		-- gjør klar verdiendring til neste klokkesyklys slik at incr_key = 0
		-- incr_key blir 0 på neste stigende klokkeflanke
		-- helt til prev_incr = 1 men da er incr_key også 1
		-- så ingen ny telling
		prev_incr <= incr_key;
	end if;
end process;

-- gjør slik at vi kan se hemmelig kode og gå tilbake til forrige inntastede kode uten problemer
gen_show : for i in temp_codes'range generate
	codes(i) <= SECRET(i) when sw9 = '1' else temp_codes(i);
end generate;

-- åpne/lukke safe om sw0 er av eller om kode er korrekt eller safen er i resett modus
open_led <= '1' when (sw0 = '0' and (match = '1' or rst_open = '1')) else '0';

-- sanntid verifisering av inntastet kode
match <= '1' when (
	temp_codes(0) = SECRET(0) and
	temp_codes(1) = SECRET(1) and
	temp_codes(2) = SECRET(2) and
	temp_codes(3) = SECRET(3)
) else '0';

-- henter hex fra segment-array og legger i segment-display-utgangen
hex0 <= hex_int(3);
hex1 <= hex_int(2);
hex2 <= hex_int(1);
hex3 <= hex_int(0);

end architecture RTL;