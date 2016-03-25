defmodule Mix.Tasks.BumpVersion do

  @version_file "VERSION"

  use Mix.Task
  @shortdoc "Updates your 'VERSION' file, and make commit, if its a git repository"

  @moduledoc """
  Updates your 'VERSION' file, and make commit, if its a git repository

      mix bump_version major -- increase major version
      mix bump_version minor -- increase minor version
      mix bump_version patch -- increase patch version [deafult]
      mix bump_version -- same as 'patch'

  This task automatically rise current App version
  it allows on convention that version is written in file with name VERSION and
  included in your mix.exs with something like

      @version File.read!("VERSION") |> String.strip

      ...

      def project do [
        version: @version
        ...
      ]

  if current code is in git repository, we automatically make commit with message
      bump version
  """

  # TODO: check if passed version is lower than in VERSION file
  def run(args) do
    check_version_file_exists()
    {_opts, args, _some} = OptionParser.parse(args)
    version_to_write = case args do
      [] -> read_and_increment_version("patch");
      [inc_type] -> read_and_increment_version(inc_type);
      value -> err_incorrect_input(value)
    end
    case File.write(@version_file, version_to_write) do
      :ok -> success_msg(version_to_write);
      {:error, reason} -> err_cant_write_file(reason)
    end
  end

  defp read_and_increment_version(inc_type) do
    File.read!(@version_file)
    |> String.strip
    |> check_version_format
    |> increment_version(inc_type)
  end

  defp check_version_file_exists() do
    if !File.exists?(@version_file) do
      err_version_file_not_exists()
    end
  end


  defp check_version_format(version) do
    case String.split(version, ".") do
      # TODO: check int
      [_first, _second, _third] -> version;
      _ -> err_incorrect_version_format(version)
    end
  end

  defp increment_version(version, inc_type) do
    [first, second, third] = String.split(version, ".") |> Enum.map(&(String.to_integer(&1)))
    Enum.join(increment_version2([first, second, third], inc_type), ".")
  end

  defp increment_version2([first, second, third], "patch") do [first, second, third + 1] end
  defp increment_version2([first, second, _third], "minor") do [first, second + 1, 0] end
  defp increment_version2([first, _second, _third], "major") do [first + 1, 0, 0] end
  defp increment_version2(_, inc_type) do err_incorrect_inc_type(inc_type) end




  #
  # outputted messages
  #
  defp success_msg(version) do
    IO.puts "
      success!
      written version: #{inspect version}
    "
  end

  defp err_incorrect_input(value) do
    err("
        incorrect input attributes: #{inspect value}
        should only contain version in format #.#.#
    ")
  end

  defp err_version_file_not_exists() do
    err("
        file '#{@version_file}' does not exist.
        your code does not follow VERSION file convention.
        read command help for info
    ")
  end

  defp err_incorrect_version_format(value) do
    err("
      incorrect version format: #{value}
      should be in #.#.# format where # -- integers
    ")
  end

  defp err_cant_write_file(reason) do
    err("
      cannot write new version to #{@version_file}
      reason: #{inspect reason}
    ")
  end

  defp err_incorrect_inc_type(inc_type) do
    err("
      wrong argument #{inspect inc_type}
      should be one of: major|minor|patch
    ")
  end



  defp err(msg) do
    IO.puts(msg)
    exit({:shutdown, 1})
  end
end


