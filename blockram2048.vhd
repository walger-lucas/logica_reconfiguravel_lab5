library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity blockram2048 is
  port (
    clk  : in  STD_LOGIC;
    we   : in  STD_LOGIC;
    addr : in  STD_LOGIC_VECTOR(10 downto 0);
    din  : in  STD_LOGIC_VECTOR(7 downto 0);
    dout : out STD_LOGIC_VECTOR(7 downto 0));
end entity;

architecture blockram2048_arch of blockram2048 is
  type ram_type is array (0 to 2047) of STD_LOGIC_VECTOR(7 downto 0);
  signal ram : ram_type := (others => (others => '0'));
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        ram(to_integer(unsigned(addr))) <= din;
      end if;
      dout <= ram(to_integer(unsigned(addr)));
    end if;
  end process;

end architecture;
