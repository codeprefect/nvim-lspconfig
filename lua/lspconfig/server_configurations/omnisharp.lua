local util = require 'lspconfig.util'

return {
  default_config = {
    -- Enables support for reading code style, naming convention and analyzer
    -- settings from .editorconfig.
    enable_editorconfig_support = true,

    -- If true, MSBuild project system will only load projects for files that
    -- were opened in the editor. This setting is useful for big C# codebases
    -- and allows for faster initialization of code navigation features only
    -- for projects that are relevant to code that is being edited. With this
    -- setting enabled OmniSharp may load fewer projects and may thus display
    -- incomplete reference lists for symbols.
    enable_ms_build_load_projects_on_demand = false,

    -- Enables support for roslyn analyzers, code fixes and rulesets.
    enable_roslyn_analyzers = false,

    -- Specifies whether 'using' directives should be grouped and sorted during
    -- document formatting.
    organize_imports_on_format = false,

    -- Enables support for showing unimported types and unimported extension
    -- methods in completion lists. When committed, the appropriate using
    -- directive will be added at the top of the current file. This option can
    -- have a negative impact on initial completion responsiveness,
    -- particularly for the first few completion sessions after opening a
    -- solution.
    enable_import_completion = false,

    -- Specifies whether to include preview versions of the .NET SDK when
    -- determining which version to use for project loading.
    sdk_include_prereleases = true,

    -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
    -- true
    analyze_open_documents_only = false,

    -- Configure inlay hints rules
    -- default to same values from Roslyn
    inlay_hints = {
      enable_for_parameters = true,
      for_literal_parameters = true,
      for_indexer_parameters = true,
      for_object_creation_parameters = true,
      for_other_parameters = true,
      enable_for_types = true,
      for_implicit_variable_types = true,
      for_lambda_parameter_types = true,
      for_implicit_object_creation = true,
      suppress_for_parameters_that_differ_only_by_suffix = false,
      suppress_for_parameters_that_match_method_intent = false,
      suppress_for_parameters_that_match_argument_name = false,
    },

    script = {
      enabled = true,
      default_target_framework = "net6.0",
      enable_script_nuGet_references = false,
    },

    filetypes = { 'cs', 'vb' },
    root_dir = function(fname)
      return util.root_pattern '*.sln'(fname) or util.root_pattern '*.csproj'(fname)
    end,
    on_new_config = function(new_config, _)
      -- Get the initially configured value of `cmd`
      new_config.cmd = { unpack(new_config.cmd or {}) }

      -- Append hard-coded command arguments
      table.insert(new_config.cmd, '-z') -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
      vim.list_extend(new_config.cmd, { '--hostPID', tostring(vim.fn.getpid()) })
      table.insert(new_config.cmd, 'DotNet:enablePackageRestore=false')
      vim.list_extend(new_config.cmd, { '--encoding', 'utf-8' })
      table.insert(new_config.cmd, '--languageserver')

      -- Append configuration-dependent command arguments
      if new_config.enable_editorconfig_support then
        table.insert(new_config.cmd, 'FormattingOptions:EnableEditorConfigSupport=true')
      end

      if new_config.organize_imports_on_format then
        table.insert(new_config.cmd, 'FormattingOptions:OrganizeImports=true')
      end

      if new_config.enable_ms_build_load_projects_on_demand then
        table.insert(new_config.cmd, 'MsBuild:LoadProjectsOnDemand=true')
      end

      if new_config.enable_roslyn_analyzers then
        table.insert(new_config.cmd, 'RoslynExtensionsOptions:EnableAnalyzersSupport=true')
      end

      if new_config.enable_import_completion then
        table.insert(new_config.cmd, 'RoslynExtensionsOptions:EnableImportCompletion=true')
      end

      if new_config.sdk_include_prereleases then
        table.insert(new_config.cmd, 'Sdk:IncludePrereleases=true')
      end

      if new_config.analyze_open_documents_only then
        table.insert(new_config.cmd, 'RoslynExtensionsOptions:AnalyzeOpenDocumentsOnly=true')
      end

      if new_config.inlay_hints.enable_for_parameters then
        table.insert(new_config.cmd, 'RoslynExtensionsOptions:InlayHintsOptions:EnableForParameters=true')
        if new_config.inlay_hints.for_literal_parameters then
          table.insert(new_config.cmd, 'RoslynExtensionsOptions:InlayHintsOptions:ForLiteralParameters=true')
        end
  
        if new_config.inlay_hints.for_indexer_parameters then
          table.insert(new_config.cmd, 'RoslynExtensionsOptions:InlayHintsOptions:ForIndexerParameters=true')
        end
  
        if new_config.inlay_hints.for_object_creation_parameters then
          table.insert(new_config.cmd, 'RoslynExtensionsOptions:InlayHintsOptions:ForObjectCreationParameters=true')
        end
  
        if new_config.inlay_hints.for_other_parameters then
          table.insert(new_config.cmd, 'RoslynExtensionsOptions:InlayHintsOptions:ForOtherParameters=true')
        end

        if new_config.inlay_hints.suppress_for_parameters_that_differ_only_by_suffix == false then
          table.insert(new_config.cmd, 'RoslynExtensionsOptions:InlayHintsOptions:SuppressForParametersThatDifferOnlyBySuffix=false')
        end
  
        if new_config.inlay_hints.suppress_for_parameters_that_match_method_intent == false then
          table.insert(new_config.cmd, 'RoslynExtensionsOptions:InlayHintsOptions:SuppressForParametersThatMatchMethodIntent=false')
        end
  
        if new_config.inlay_hints.suppress_for_parameters_that_match_argument_name == false then
          table.insert(new_config.cmd, 'RoslynExtensionsOptions:InlayHintsOptions:SuppressForParametersThatMatchArgumentName=false')
        end
      end

      if new_config.inlay_hints.enable_for_types then
        table.insert(new_config.cmd, 'RoslynExtensionsOptions:InlayHintsOptions:EnableForTypes=true')
        if new_config.inlay_hints.for_implicit_variable_types then
          table.insert(new_config.cmd, 'RoslynExtensionsOptions:InlayHintsOptions:ForImplicitVariableTypes=true')
        end
  
        if new_config.inlay_hints.for_lambda_parameter_types then
          table.insert(new_config.cmd, 'RoslynExtensionsOptions:InlayHintsOptions:ForLambdaParameterTypes=true')
        end
  
        if new_config.inlay_hints.for_implicit_object_creation then
          table.insert(new_config.cmd, 'RoslynExtensionsOptions:InlayHintsOptions:ForImplicitObjectCreation=true')
        end
      end

      if new_config.scripts.enabled then
        table.insert(new_config.cmd, 'Script:Enabled=true')
        table.insert(new_config.cmd, 'Script:DefaultTargetFramework=' .. new_config.script.default_target_framework)
        if (new_config.script.enable_script_nuget_references) then
          table.insert(new_config.cmd, 'Script:EnableScriptNuGetReferences=true')
        end
      end

      -- Disable the handling of multiple workspaces in a single instance
      new_config.capabilities = vim.deepcopy(new_config.capabilities)
      new_config.capabilities.workspace.workspaceFolders = false -- https://github.com/OmniSharp/omnisharp-roslyn/issues/909
    end,
    init_options = {},
  },
  docs = {
    description = [[
https://github.com/omnisharp/omnisharp-roslyn
OmniSharp server based on Roslyn workspaces

`omnisharp-roslyn` can be installed by downloading and extracting a release from [here](https://github.com/OmniSharp/omnisharp-roslyn/releases).
OmniSharp can also be built from source by following the instructions [here](https://github.com/omnisharp/omnisharp-roslyn#downloading-omnisharp).

OmniSharp requires the [dotnet-sdk](https://dotnet.microsoft.com/download) to be installed.

**By default, omnisharp-roslyn doesn't have a `cmd` set.** This is because nvim-lspconfig does not make assumptions about your path. You must add the following to your init.vim or init.lua to set `cmd` to the absolute path ($HOME and ~ are not expanded) of the unzipped run script or binary.

For `go_to_definition` to work fully, extended `textDocument/definition` handler is needed, for example see [omnisharp-extended-lsp.nvim](https://github.com/Hoffs/omnisharp-extended-lsp.nvim)

```lua
require'lspconfig'.omnisharp.setup {
    cmd = { "dotnet", "/path/to/omnisharp/OmniSharp.dll" },

    -- Enables support for reading code style, naming convention and analyzer
    -- settings from .editorconfig.
    enable_editorconfig_support = true,

    -- If true, MSBuild project system will only load projects for files that
    -- were opened in the editor. This setting is useful for big C# codebases
    -- and allows for faster initialization of code navigation features only
    -- for projects that are relevant to code that is being edited. With this
    -- setting enabled OmniSharp may load fewer projects and may thus display
    -- incomplete reference lists for symbols.
    enable_ms_build_load_projects_on_demand = false,

    -- Enables support for roslyn analyzers, code fixes and rulesets.
    enable_roslyn_analyzers = false,

    -- Specifies whether 'using' directives should be grouped and sorted during
    -- document formatting.
    organize_imports_on_format = false,

    -- Enables support for showing unimported types and unimported extension
    -- methods in completion lists. When committed, the appropriate using
    -- directive will be added at the top of the current file. This option can
    -- have a negative impact on initial completion responsiveness,
    -- particularly for the first few completion sessions after opening a
    -- solution.
    enable_import_completion = false,

    -- Specifies whether to include preview versions of the .NET SDK when
    -- determining which version to use for project loading.
    sdk_include_prereleases = true,

    -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
    -- true
    analyze_open_documents_only = false,
}
```
]],
    default_config = {
      root_dir = [[root_pattern(".sln") or root_pattern(".csproj")]],
    },
  },
}
