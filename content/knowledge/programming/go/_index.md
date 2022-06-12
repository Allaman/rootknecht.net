---
title: Go
---

{{< toc >}}

## Structs

```go
type status struct {
	status bool
	cores float64
	memory float64
}

s := status{power, cores, memory}
```

## Print formatted string

```go
fmt.Printf("Current Status: Power %v, Cores %v, Memory %v", s.status, s.cores, s.memory)
```

## Format string without printing

```go
fmt.Sprintf("{\"cores\": %v}", cores)
```

### Get

```go
resp, err := resty.R().
		SetHeaders(map[string]string{"Content-Type": "application/json", "X-Auth-UserId": userID,"X-Auth-Token": token}).
		Get(baseURL + endpoint)
if err != nil || resp.StatusCode() != 200 {
	// error handling
}
```

## net/http

Have a look at [simple http](https://github.com/Allaman/toolbox/tree/main/http-client/simple) and [parallel http](https://github.com/Allaman/toolbox/tree/main/http-client/parallel) where I demonstrate Go's net/http package.

## Logging

In my [toolbox](https://github.com/Allaman/toolbox/) repository I demonstrate an approach for a global [logger](https://github.com/Allaman/toolbox/tree/main/golang/logging) in Go.

## Load json data

### "Dynamically" typed

```go
var data map[string]interface{}
err = json.Unmarshal([]byte(resp.Body()), &data)
// access data
var power = data["power"].(bool)
// access nested data
var cores = data["server"].(map[string]interface{})["cores"].(float64)
```

### Statically typed

```go
// TODO
```

## Args and ENV

```go
func main() {
	statsCmd := flag.NewFlagSet("stats", flag.ExitOnError)

	// Flags for stats subcommand
    // reads from Env var and command line
	statsDebugPtr := statsCmd.Bool("debug", getBoolEnv("FOO_DEBUG", false), "enable debugging")
}

func getBoolEnv(key string, defaultValue bool) bool {
	if val, ok := getEnv(key); ok {
		boolVal, err := strconv.ParseBool(val)
		if err != nil {
			return false
		}
		return boolVal
	}
	return defaultValue
}

func getEnv(key string) (string, bool) {
	val, ok := os.LookupEnv(key)
	if !ok {
		return "", ok
	}
	return val, ok
}

```

## Building a CLI

Please refer to my Github [Go CLI](https://github.com/Allaman/toolbox/tree/main/golang/cli) repository for a demonstration of how to build CLI applications with different methods.

## Convert Unix ms timestamp to time

```go
func msToTime(ms string) (time.Time, error) {
	msInt, err := strconv.ParseInt(ms, 10, 64)
	if err != nil {
		return time.Time{}, err
	}

	return time.Unix(0, msInt*int64(time.Millisecond)), nil
}

```
