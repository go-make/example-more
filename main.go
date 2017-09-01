package main

import (
	"log"
	"os"

	"github.com/gravitational/version"
	"github.com/urfave/cli"
)

func main() {
	v := version.Get()
	app := cli.NewApp()
	app.Name = "example-more"
	app.Usage = "A go-make example using various different tools"
	app.Version = v.Version
	app.EnableBashCompletion = true
	app.Flags = []cli.Flag{}
	app.Commands = []cli.Command{
		cmdServe,
	}
	err := app.Run(os.Args)
	if err != nil {
		log.Print(err)
	}
}
