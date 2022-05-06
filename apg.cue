package main

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
	"strings"
)

image: docker.#Pull & {
	source: "node"
}

proxiesRoot: _source.output
_source:     core.#Source & {path: "./proxies"}

dagger.#Plan & {
	actions: {
		deployAll: {
			proxies: string | *"" //comma-separated list of proxy dirs
			for proxy in strings.Split(proxies, ",") {
				"create_proxy_\(proxy)": docker.#Run & {
					command: {
						name: "/bin/sh"
						args: ["-c", "ls -R -al /source/\(proxy)"]
					}
					input:  image.output
					always: true
					mounts: proxy: {
						contents: proxiesRoot
						ro:       true
						dest:     "/source"
						type:     "fs"
					}
				}
			}
		}
	}
}
