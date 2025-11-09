library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ClockGen is
    port (
        clk_50Mhz_in       : in  std_logic;
        reset_n_in         : in  std_logic;   
        enable_in          : in  std_logic;  
        htol_1s_toggle     : out std_ulogic;
        htol_1Mhz_toggle   : out std_ulogic;
        htol_50Mhz_toggle  : out std_ulogic
    );
end ClockGen;

architecture RTL of ClockGen is
    constant CLK_FREQ      : integer := 50_000_000; 
    constant ONE_HZ_COUNT  : integer := CLK_FREQ / 2; 
    constant ONE_MHZ_COUNT : integer := 25;          

    signal cnt_1s  : unsigned(25 downto 0) := (others => '0');
    signal cnt_1M  : unsigned(5 downto 0)  := (others => '0');
    signal toggle_1s   : std_ulogic := '0';
    signal toggle_1Mhz : std_ulogic := '0';

begin

    process(clk_50Mhz_in, reset_n_in)
    begin
        if reset_n_in = '0' then
            cnt_1s       <= (others => '0');
            cnt_1M       <= (others => '0');
            toggle_1s    <= '0';
            toggle_1Mhz  <= '0';

        elsif rising_edge(clk_50Mhz_in) then
            if enable_in = '1' then
                -- 1 Hz counter
                if cnt_1s = ONE_HZ_COUNT-1 then
                    cnt_1s <= (others => '0');
                    toggle_1s <= not toggle_1s;
                else
                    cnt_1s <= cnt_1s + 1;
                end if;

                -- 1 MHz counter
                if cnt_1M = ONE_MHZ_COUNT-1 then
                    cnt_1M <= (others => '0');
                    toggle_1Mhz <= not toggle_1Mhz;
                else
                    cnt_1M <= cnt_1M + 1;
                end if;

            else
                cnt_1s       <= (others => '0');
                cnt_1M       <= (others => '0');
                toggle_1s    <= '0';
                toggle_1Mhz  <= '0';
            end if;
        end if;
    end process;

    htol_1s_toggle   <= toggle_1s;
    htol_1Mhz_toggle <= toggle_1Mhz;
    htol_50Mhz_toggle <= clk_50Mhz_in when enable_in = '1' else '0';

end RTL;
