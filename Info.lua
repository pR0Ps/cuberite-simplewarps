g_PluginInfo =
{
  Name = "SimpleWarps",
  Version = "1",
  Date = "2019-03-11",
  SourceLocation = "https://github.com/pR0Ps/cuberite-simplewarps",
  Description = "Manage and use named warp locations",
  AdditionalInfo = {
    {
      Title = "Creating and using warp signs",
      Contents =  "1) Create a sign\n2) Make the first line \"[Warp]\"\n3) Make the second line the name of a warp point.\n4) Optionally add other text to the 3rd line.\n5) Save.\n6) Right-click the sign to warp to the specified location."
    },
  },
  Commands = {
    ["/warp"] = {
      Subcommands = {
        help = {
          HelpString = "Help on using warps",
          Handler = WarpHelp,
        },

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
