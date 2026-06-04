---
title: "Ein Azure DevOps-Repo mit Stil wiederherstellen (feat: kulala.nvim)"
description: "Azure, DevOps, API, Neovim, REST, kulala.nvim"
summary: Wie man .http-Dateien mit Neovim verwendet, um ein gelöschtes Azure DevOps-Repository wiederherzustellen
draft: false
date: 2025-11-23
tags:
  - Neovim
  - Azure
  - Tools
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/restore-ado-repo-with-kulala-nvim/)
{{< /alert >}}

Kürzlich entdeckte ich, dass es nicht möglich ist, ein gelöschtes Repository über die UI in Azure DevOps wiederherzustellen.

Stattdessen muss die API verwendet werden, was eine gute Gelegenheit für ein einfaches Beispiel mit [kulala.nvim](https://neovim.getkulala.net/) bietet.

> A minimal REST-Client Interface for Neovim.

## Kulala.nvim

Es gibt viele Optionen für API-Aufrufe, von [curl](https://curl.se/) und [httpie](https://httpie.io/) über [Hurl](https://hurl.dev/) (ein ausgezeichnetes Tool, das ich für das [Testen dieser Seite](/blog/testing-homepage/) verwende) bis hin zu [bruno](https://www.usebruno.com/), [Insomnia](https://insomnia.rest/), [Postman](https://www.postman.com/) und vielen mehr.

Dennoch entschied ich mich für [kulala.nvim](https://neovim.getkulala.net/), weil ich ein großer Neovim-Fan bin und die Idee mag, `.http`[^1]-Dateien zu haben, die von verschiedenen Editoren/IDEs verstanden werden[^2].

Meine Konfiguration für Kulala.nvim ist sehr einfach:

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

Ich habe auch `kulala-fmt` zu [conform.nvim](stevearc/conform.nvim) und `kulala_ls` zu [nvim-lspconfig](neovim/nvim-lspconfig) für Autovervollständigung und Formatierung hinzugefügt.

## Ein Azure DevOps-Repository wiederherstellen

Ein soft-gelöschtes Repo kann „für eine bestimmte Zeit" ([Dokumentation](https://learn.microsoft.com/en-us/rest/api/azure/devops/git/repositories/restore-repository-from-recycle-bin?view=azure-devops-rest-7.1)) wiederhergestellt werden.

Die Wiederherstellung über die API umfasst zwei API-Aufrufe:

1. Alle soft-gelöschten Repositories auflisten, um die wiederherzustellende Repo-ID zu suchen
2. Die Repository-ID wiederherstellen

Für die Organisation wird ein PAT mit vollständigem Zugriffsbereich benötigt.

Die eigene Organisation (`@ADO`) und das Projekt (`@ADO_PROJECT`) anpassen:

```http
@ADO = <orga>
@ADO_PROJECT = <projekt>


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

Mit dem Cursor über der ersten Anfrage kann „Anfrage senden" (`<leader>Hs`) ausgeführt werden, was nach Benutzer und PAT fragt.

{{< figure src=prompt.png caption="Nach einer ID fragen" >}}

Eine Antwort wird in einem Split-Buffer angezeigt.

{{< figure src=repos.png caption="Liste aller gelöschten Repositories" >}}

Die ID des wiederherzustellenden Repositories kopieren, den Cursor über die zweite Anfrage setzen und „Anfrage senden" erneut ausführen, was nach der ID fragt und das Repository durch Patchen eines JSON-Objekts wiederherstellt.

## Vorteile

- Dokumentation zusammen mit den Anfragen
- .http-Dateien in der Versionskontrolle
- Reproduzierbar
- Neovim-Mappings und modales Bearbeiten in Anfrage und Antwort

[^1]: Kulala.nvim hat eine gute [Dokumentation](https://neovim.getkulala.net/docs/usage/http-file-spec) zur `.http`-Dateispezifikation.

[^2]: [VSC](https://marketplace.visualstudio.com/items?itemName=humao.rest-client), [Intellij](https://www.jetbrains.com/help/idea/http-client-in-product-code-editor.html), [VS](https://learn.microsoft.com/en-us/aspnet/core/test/http-files?view=aspnetcore-10.0&WT.mc_id=DT-MVP-5004452).
