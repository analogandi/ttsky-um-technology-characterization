library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity InverterChain is
    generic (
        g_sim     : boolean := false;
        chain_len : natural := 1024;
        sim_delay : time    := 5 ns
    );
    port(
        chain_in   : in  std_logic;
        chain_mid  : out std_logic;
        chain_3q   : out std_logic;
        chain_out  : out std_logic
    );
end InverterChain;

architecture RTL of InverterChain is

    signal chain : std_logic_vector(chain_len downto 0);
    attribute keep : string;
    attribute keep of chain : signal is "yes";

    component inv_hd_1_wrapper
        port (
            A : in  std_logic;
            Y : out std_logic
        );
    end component;

begin

    chain(0) <= chain_in;

    GEN_INV : for i in 0 to chain_len-1 generate
        SIM_INV : if g_sim generate
            chain(i+1) <= not chain(i) after sim_delay;
        end generate;

        SYN_INV : if not g_sim generate
            INV_INST : inv_hd_1_wrapper
                port map(
                    A => chain(i),
                    Y => chain(i+1)
                );
        end generate;
    end generate;

    chain_mid <= chain(chain_len/2);
    chain_3q  <= chain((3*chain_len)/4);
    chain_out <= chain(chain_len);

end RTL;
