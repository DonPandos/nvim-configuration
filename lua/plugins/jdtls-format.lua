return {
  "mfussenegger/nvim-jdtls",
  opts = {
    root_dir = function(fname)
      return vim.fs.root(fname, { "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts" })
    end,
    settings = {
      java = {
        format = {
          settings = {
            url = vim.fn.expand("~/.config/nvim/java-formatter.xml"),
            profile = "Default",
          },
        },
      },
    },
  },
}
