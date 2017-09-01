package main

import (
	"log"

	"github.com/gravitational/version"
	"github.com/urfave/cli"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

var cmdServe = cli.Command{
	Name:  "serve",
	Usage: "starts an agent daemon",
	Flags: []cli.Flag{
		cli.StringFlag{
			Name:   "bind, b",
			Usage:  "Specifies the socket address used for the agent GRPC server",
			Value:  "127.0.0.1:8000",
			EnvVar: "BIND",
		},
		cli.StringFlag{
			Name:   "dispatcher-url, d",
			Usage:  "Specifies the URL of the dispatcher service",
			Value:  "http://dispatcher/",
			EnvVar: "DISPATCHER_URL",
		},
		cli.StringFlag{
			Name:   "meta-url, m",
			Usage:  "Specifies the metadata url of the metadata webserver",
			Value:  "http://metadata/openstack/latest",
			EnvVar: "METADATA_URL",
		},
		// cli.StringFlag{
		// 	Name:   "metadata-mode, m",
		// 	Usage:  "Specifies the job metadata mode - userdata or environment",
		// 	Value:  "userdata",
		// 	EnvVar: "METADATA_MODE",
		// },
		// cli.StringFlag{
		// 	Name:   "res-id, r",
		// 	Usage:  "DEV - manually specifies the resource ID rather than reading metadata",
		// 	Value:  "",
		// 	Hidden: true,
		// },
	},
	Action: func(c *cli.Context) {
		v := version.Get()
		log.Println("starting", c.App.Name, v.Version)

		s := grpc.NewServer()
		reflection.Register(s)
	},
}
