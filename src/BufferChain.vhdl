library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BufferChain is
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
end BufferChain;

architecture RTL of BufferChain is

    signal chain : std_logic_vector(chain_len downto 0);
    attribute keep : string;
    attribute keep of chain : signal is "yes";

    component buf_hd_1_wrapper
        port (
            A : in  std_logic;
            Y : out std_logic
        );
    end component;

begin

    chain(0) <= chain_in;

    GEN_BUF : for i in 0 to chain_len-1 generate
        SIM_BUF : if g_sim generate
            chain(i+1) <= chain(i) after sim_delay;
        end generate;

        SYN_BUF : if not g_sim generate
            BUF_INST : buf_hd_1_wrapper
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
