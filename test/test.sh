#!/bin/bash
set -e

wait_for_url () {
    echo "Testing $1"
    max_in_s=$2
    delay_in_s=1
    total_in_s=0
    while [ $total_in_s -le "$max_in_s" ]
    do
        echo "Wait ${total_in_s}s"
        if (echo -e "GET $1\nHTTP/* 200" | hurl > /dev/null 2>&1;) then
            return 0
        fi
        total_in_s=$(( total_in_s +  delay_in_s))
        sleep $delay_in_s
    done
    return 1
}

echo "Building Docker image"
docker buildx build -t rootknecht . --load

echo "Starting container"
docker run --name rootknecht --rm --detach --publish 1313:1313 rootknecht

echo "Waiting for container"
wait_for_url 'http://localhost:1313' 60

echo "Running Hurl tests"
hurl --test test/test.hurl

echo "Stopping container"
docker stop rootknecht
