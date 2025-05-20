library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_blockram2048 is
end entity;

architecture sim of tb_blockram2048 is

  -- Componente a ser testado
  component blockram2048
    port (
      clk  : in  STD_LOGIC;
      we   : in  STD_LOGIC;
      addr : in  STD_LOGIC_VECTOR(10 downto 0);
      din  : in  STD_LOGIC_VECTOR(7 downto 0);
      dout : out STD_LOGIC_VECTOR(7 downto 0)
    );
  end component;

  -- Sinais para interconexão
  signal clk  : STD_LOGIC := '0';
  signal we   : STD_LOGIC := '0';
  signal addr : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
  signal din  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
  signal dout : STD_LOGIC_VECTOR(7 downto 0);

  -- Clock de 10 ns
  constant clk_period : time := 10 ns;

begin

  -- Instancia o componente
  uut: blockram2048
    port map (
      clk  => clk,
      we   => we,
      addr => addr,
      din  => din,
      dout => dout
    );

  -- Geração do clock
  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
    end loop;
  end process;

  -- Estímulos
  stim_proc : process
  begin
    -- Escrita no endereço 5
    wait for 20 ns;
    addr <= std_logic_vector(to_unsigned(5, 11));
    din  <= x"AB";
    we   <= '1';
    wait for clk_period;

    -- Escrita no endereço 10
    addr <= std_logic_vector(to_unsigned(10, 11));
    din  <= x"CD";
    wait for clk_period;

    -- Desabilita escrita para iniciar leitura
    we <= '0';

    -- Leitura do endereço 5
    addr <= std_logic_vector(to_unsigned(5, 11));
    wait for clk_period;

    -- Leitura do endereço 10
    addr <= std_logic_vector(to_unsigned(10, 11));
    wait for clk_period;

    -- Finaliza simulação
    wait for 20 ns;
  end process;

end architecture;
