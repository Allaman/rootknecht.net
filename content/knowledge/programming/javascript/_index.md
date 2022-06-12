---
title: Javascript
---

My notes on Javascript

{{< toc >}}

## File globbing

```javascript
glob.sync("../*/*.xlsm").forEach(function (file) {
  console.log(file);
});
```

## Read subfolders

```javascript
dirs = FS.readdirSync(path);
```

## Convert Time

```javascript
let date = moment(
  "01/23/18",
  ["MM/DD/YY", "M/DD/YY", "MM/D/YY", "M/D/YY"],
  true
);
if (date.isValid()) {
  console.log(date.format("DD.MM.YY"));
}
```

## Check for undefined and not null

```javascript
if (typeof variable != "undefined" && variable) {
  console.log("Good");
}
```

## For loops

```javascript
for (let input of inputs) {
  console.log(input);
}
```

## IE not rendering Javascript

```html
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
</head
```

## Transpiler error lines mapping

Add to your entrypoint the following snippet

```javascript
require("source-map-support").install();
```

```bash
npm install dev-dependencies source-map-support
```

## Reload content on change

index.html

```html
<script type="text/javascript">
  app.main();
</script>
<body>
  <form>
    <select id="year" name="year">
      <option value="2017">2017</option>
      <option selected="selected" value="2018">2018</option>
    </select>
  </form>
</body>
```

app.js

```javascript
static main () {
    $(document).ready(() => {
        this.draw() // do stuff
        $("#year").change(() => {
            this.draw()
        })
    })
}
```

## Set content of textarea

```javascript
document.getElementById("id").value = data;
```

## NPM

### Module management

```bash
npm list -g --depth=0
npm uninstall -g MODULE
```

Remove all global modules:

```powershell
del %APPDATA%\npm
```

```bash
npm ls -gp --depth=0 | awk -F/ '/node_modules/ && !/\/npm$/ {print $NF}' | xargs npm -g rm
```

Automatically check your dependencies in your package.json for vulnerabilities

```bash
npm install auditjs -g
```

### Settings

```bash
npm config [--global] set|delete strict-ssl false|true
npm config [--global] set|delete cafile CAFILE
npm config [--global] set|delete proxy PROXY
npm config [--global] set|delete https-proxy PROXY
```

### Ignore certificates

```bash
npm config set strict-ssl false
```

### Set loglevel

```bash
npm config set loglevel error
```
