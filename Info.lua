g_PluginInfo =
{
  Name = "SimpleWarps",
  Version = "1",
  Date = "2019-03-11",
  SourceLocation = "https://github.com/pR0Ps/cuberite-simplewarps",
  Description = "Manage and use named warp locations",
  Commands = {
    ["/warp"] = {
      Subcommands = {
        to = {
          HelpString = "Warp to a named warp point",
          Permission = "simplewarps.use",
          Handler = UseWarp,
          ParameterCombinations = {
            {
              Params = "name",
              Help = "Warp to the specified warp point",
            },
          },
        },

        ls = {
          HelpString = "List all warp points by name",
          Permission = "simplewarps.list",
          Handler = ListWarps,
        },

        set = {
          HelpString = "Set a named warp point",
          Permission = "simplewarps.set",
          Handler = SetWarp,
          ParameterCombinations = {
            {
              Params = "name",
              Help = "Set a named warp point at your current location"
            },
          },
        },

        rm = {
          HelpString = "Remove a named warp point",
          Permission = "simplewarps.remove",
          Handler = RemoveWarp,
          ParameterCombinations = {
            {
              Params = "name",
              Help = "Remove a named warp point",
            },
          },
        },
      },
    },
  },
}
