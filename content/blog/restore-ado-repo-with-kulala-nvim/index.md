---
title: "Restore an Azure DevOps repo with style (feat: kulala.nvim)"
description: "Azure, DevOps, API, Neovim, REST, kulala.nvim"
summary: How to use .http files with Neovim to restore a deleted Azure DevOps repository
draft: false
date: 2025-11-23
tags:
  - Neovim
  - Azure
  - Tools
---

Recently, I discovered that it is not possible to restore a deleted repository through the UI in Azure DevOps.

Instead, one has to utilize the API, which provides a good opportunity for a simple example of [kulala.nvim](https://neovim.getkulala.net/)

> A minimal REST-Client Interface for Neovim.

## Kulala.nvim

There are many options for calling APIs from [curl](https://curl.se/) and [httpie](https://httpie.io/), over to [Hurl](https://hurl.dev/) (excellent tool I use for [testing this page](/blog/testing-homepage/)) to [bruno](https://www.usebruno.com/), [Insomnia](https://insomnia.rest/), [Postman](https://www.postman.com/), and many more.

Nevertheless, I decided to use [kulala.nvim](https://neovim.getkulala.net/) because I am a big Neovim fanboy and I like the idea of having `.http`[^1] files that can be understood by various Editors/IDEs[^2].

My configuration for Kulala.nvim is very basic:

```lua
  {
    "mistweaverco/kulala.nvim",
    keys = {
      { "<leader>Hs", desc = "Send request" },
      { "<leader>Ha", desc = "Send all requests" },
      { "<leader>Hb", desc = "Open scratchpad" },
    },
    ft = { "http", "rest" },
    opts = {
      global_keymaps = true,
      global_keymaps_prefix = "<leader>H",
      kulala_keymaps_prefix = "",
    },
  },
```

I also added `kulala-fmt` to [conform.nvim](stevearc/conform.nvim) and `kulala_ls` to [nvim-lspconfig](neovim/nvim-lspconfig) for autocompletion and formatting.

## Restoring an Azure DevOps repository

A soft-deleted repo can be restored "for a period of time" ([doc](https://learn.microsoft.com/en-us/rest/api/azure/devops/git/repositories/restore-repository-from-recycle-bin?view=azure-devops-rest-7.1).

Restoring via API involves two API calls:

1. List all soft deleted repositories to look up the repo ID to be restored
2. Restore the repository ID

You will need a PAT with Full Access Scope for the organization.

Adjust your organization (`@ADO`) and project (`@ADO_PROJECT`):

```http
@ADO = <orga>
@ADO_PROJECT = <project>


###

# Returns a list of deleted repos filtered by ID and Name
# @jq { "ids": .value[].id, "names": .value[].name }
# @prompt user
# @prompt token
GET https://dev.azure.com/{{ADO}}/{{ADO_PROJECT}}/_apis/git/deletedrepositories?api-version=5.1-preview.1 HTTP/1.1
Authorization: Basic {{user}}:{{token}}

###

# Restores a given repo ID
# @prompt user
# @prompt token
# @prompt id
PATCH https://dev.azure.com/{{ADO}}/{{ADO_PROJECT}}/_apis/git/recycleBin/repositories/{{id}}?api-version=5.1-preview.1 HTTP/1.1
Authorization: Basic {{user}}:{{token}}

{
    "deleted":false
}
```

With the cursor over the first request I can run "Send request" (`<leader>Hs`) which will ask for the user and PAT.

{{< figure src=prompt.png caption="Asking for an ID" >}}

A response is shown in a split buffer

{{< figure src=repos.png caption="List of all deleted repositories" >}}

Copy the ID of the repository to restore and put the cursor over the second request and run "Send request" again which will ask for the ID and restores the repository by patching a JSON object.

## Benefits

- Documentation along the requests
- .http files in version control
- Reproducible
- Neovim mappings and modal editing in request and response

[^1]: Kulala.nvim has good [documentation](https://neovim.getkulala.net/docs/usage/http-file-spec) for the `.http` file spec

[^2]: [VSC](https://marketplace.visualstudio.com/items?itemName=humao.rest-client), [Intellij](https://www.jetbrains.com/help/idea/http-client-in-product-code-editor.html), [VS](https://learn.microsoft.com/en-us/aspnet/core/test/http-files?view=aspnetcore-10.0&WT.mc_id=DT-MVP-5004452)
