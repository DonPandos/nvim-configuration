return {
  -- Spring Boot LS integration: bean/endpoint workspace symbols, code actions,
  -- and application.properties / application.yml completion + navigation.
  {
    "JavaHello/spring-boot.nvim",
    ft = { "java", "yaml", "jproperties" },
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "ibhagwan/fzf-lua",
    },
    ---@type bootls.Config
    opts = {},
  },

  -- Hand the Spring Boot jdtls extension jars to the jdtls that LazyVim starts.
  -- LazyVim's java extra applies opts.jdtls (as a function) to the final config
  -- right before require("jdtls").start_or_attach(config), so this is where the
  -- bundles must be appended -- without it, jdtls never loads the STS4 extension
  -- and the Java-side Spring features stay dead.
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts.jdtls = function(config)
        config.init_options = config.init_options or {}
        config.init_options.bundles = config.init_options.bundles or {}
        vim.list_extend(config.init_options.bundles, require("spring_boot").java_extensions())
        return config
      end
    end,
  },
}
