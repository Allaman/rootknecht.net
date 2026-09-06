## code block with title and line highlights

```nginx {title="nginx.conf" lineNos=inline hl_lines=[4,"7-9"]}
server {
        server_name  example.com;
        client_max_body_size 20480m;
```

tabs shortcurt now <https://github.com/nunocoracao/blowfish/pull/2637>

## goat diagrams as alternative to mermaid

```goat
      .               .                .               .--- 1          .-- 1     / 1
     / \              |                |           .---+            .-+         +
    /   \         .---+---.         .--+--.        |   '--- 2      |   '-- 2   / \ 2
   +     +        |       |        |       |    ---+            ---+          +
  / \   / \     .-+-.   .-+-.     .+.     .+.      |   .--- 3      |   .-- 3   \ / 3
 /   \ /   \    |   |   |   |    |   |   |   |     '---+            '-+         +
 1   2 3   4    1   2   3   4    1   2   3   4         '--- 4          '-- 4     \ 4

```
