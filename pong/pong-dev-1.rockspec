package = "pong"
version = "dev-1"
source = {
	url = "*** please add URL for source tarball, zip or repository here ***",
}
description = {
	homepage = "*** please enter a project homepage ***",
	license = "*** please specify a license ***",
}
dependencies = {
	"lua ~> 5.4",
	"push ~> 0.1-1",
}
build = {
	type = "builtin",
	modules = {
		main = "main.lua",
	},
}
