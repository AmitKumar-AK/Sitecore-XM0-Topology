# Sitecore XM0 Topology
[![GitHub license](https://img.shields.io/github/license/amitkumar-ak/Sitecore-XM0-Topology.svg?style=for-the-badge)](https://github.com/amitkumar-ak/Sitecore-XM0-Topology/blob/master/LICENSE)
[![GitHub contributors](https://img.shields.io/github/contributors/amitkumar-ak/Sitecore-XM0-Topology.svg?style=for-the-badge)](https://GitHub.com/amitkumar-ak/Sitecore-XM0-Topology/graphs/contributors/)
[![GitHub issues](https://img.shields.io/github/issues/amitkumar-ak/Sitecore-XM0-Topology.svg?style=for-the-badge)](https://GitHub.com/amitkumar-ak/Sitecore-XM0-Topology/issues/)
[![GitHub pull-requests](https://img.shields.io/github/issues-pr/amitkumar-ak/Sitecore-XM0-Topology.svg?style=for-the-badge)](https://GitHub.com/amitkumar-ak/Sitecore-XM0-Topology/pulls/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge)](http://makeapullrequest.com)
[![GitHub Stars](https://img.shields.io/github/stars/amitkumar-ak/Sitecore-XM0-Topology?label=GitHub%20Stars&style=for-the-badge)](https://github.com/amitkumar-ak/Sitecore-XM0-Topology/stargazers)
![Visitors](https://api.visitorbadge.io/api/visitors?path=https%3A%2F%2Fgithub.com%2FAmitKumar-AK%2FSitecore-XM0-Topology&label=Visitors&countColor=%23263759&style=for-the-badge)
![GitHub language count](https://img.shields.io/github/languages/count/amitkumar-ak/Sitecore-XM0-Topology.svg?style=for-the-badge)
![GitHub repo size](https://img.shields.io/github/repo-size/amitkumar-ak/Sitecore-XM0-Topology.svg?style=for-the-badge)
![GitHub commit activity](https://img.shields.io/github/commit-activity/y/amitkumar-ak/Sitecore-XM0-Topology?style=for-the-badge)

[![GitHub watchers](https://img.shields.io/github/watchers/amitkumar-ak/Sitecore-XM0-Topology.svg?style=social&label=Watch&maxAge=2592000)](https://GitHub.com/amitkumar-ak/Sitecore-XM0-Topology/watchers/)
[![GitHub forks](https://img.shields.io/github/forks/amitkumar-ak/Sitecore-XM0-Topology.svg?style=social&label=Fork&maxAge=2592000)](https://GitHub.com/amitkumar-ak/Sitecore-XM0-Topology/network/)
[![GitHub stars](https://img.shields.io/github/stars/amitkumar-ak/Sitecore-XM0-Topology.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/amitkumar-ak/Sitecore-XM0-Topology/stargazers/)
## About this Solution
This solution is designed to help developers learn and get started quickly
with Sitecore Containers, the Sitecore Next.js SDK, and Sitecore
Content Serialization.

For simplicity, this solution does not implement Sitecore Helix conventions for
solution architecture. As you begin building your Sitecore solution,
you should review [Sitecore Helix](https://helix.sitecore.net/) and the
[Sitecore Helix Examples](https://sitecore.github.io/Helix.Examples/) for guidance
on implementing a modular solution architecture.

*This repo will provide Sitecore Container images for XP0, XP1, XM0 and XM1 topologies. With [`Sitecore XM0 Topology`](https://doc.sitecore.com/xp/en/developers/103/sitecore-experience-manager/sitecore-configurations-and-topology-for-azure.html#xm-single) Container Images, you can encapsulate the entire [Sitecore XM](https://doc.sitecore.com/xp/en/users/latest/sitecore-experience-platform/experience-manager.html) environment, including its dependencies, configurations, and code, into a lightweight, isolated container.*

This repository uses:

* Sitecore Images Version <strong>10.4.0-ltsc2022</strong>
* Sitecore Management Services Image <strong>5.2.113-ltsc2022</strong>
* Sitecore Docker Tools (TOOLS_IMAGE) Image <strong>10.3.0-ltsc2022</strong>
* Traefik Image <strong>v2.9.8-windowsservercore-1809</strong>
* Sitecore Headless Services Image <strong>21.0-1809</strong>

## Configured for Sitecore-based workflow
On first run, the JSS Styleguide sample will be imported via `jss deploy items`, then serialized via `sitecore ser pull`. It is intended that you work directly in Sitecore to define templates and renderings, instead of using the code-first approach. This is also known as "Sitecore-first" JSS workflow. To support this:

* The JSS content workflow is disabled
* Imported items will not be marked as 'protected'
* JSS import warnings in the Content Editor and Experience Editor have been disabled

The code-first Sitecore definitions and routes remain in the JSS project, in case you wish to use them for local development / mocking. You can remove these from `/data` and `/sitecore` if desired. You may also wish to remove the [initial import logic in the `up.ps1` script](./up.ps1#L44).


## Support
The template output as provided is supported by Sitecore. Once changed or amended,
the solution becomes a custom implementation and is subject to limitations as
defined in Sitecore's [scope of support](https://kb.sitecore.net/articles/463549#ScopeOfSupport).

## Prerequisites
* NodeJs 16.x
* .NET 6.0 SDK
* .NET Framework 4.8 SDK
* Visual Studio 2019
* Docker for Windows, with Windows Containers enabled

See Sitecore Containers documentation for more information on system requirements.

## What's Included
* A `docker-compose` environment for each Sitecore topology (XPO, XP1, XM1)
  with an ASP.NET Core rendering host.
  > The containers structure is organized by specific topology environment (see `run\sitecore-xp0`, `run\sitecore-xp1`, `run\sitecore-xm1`).
  > The included `docker-compose.yml` is a stock environment from the Sitecore
  > Container Support Package. All changes/additions for this solution are included
  > in the `docker-compose.override.yml`.

* Scripted invocation of `jss create` and `jss deploy` to initialize a
  Next.js application.
* Sitecore Content Serialization configuration.
* An MSBuild project for deploying configuration and code into
  the Sitecore Content Management role. (see `src\platform`).

## Running this Solution
1. If your local IIS is listening on port 443, you'll need to stop it.
   > This requires an elevated PowerShell or command prompt.
   ```
   iisreset /stop
   ```

1. Before you can run the solution, you will need to prepare the following
   for the Sitecore container environment:
   * A valid/trusted wildcard certificate for `*.contosoproject.localhost`
   * Hosts file entries for `contosoproject.localhost`
   * Required environment variable values in `.env` for the Sitecore instance
     * (Can be done once, then checked into source control.)

   See Sitecore Containers documentation for more information on these
   preparation steps. The provided `init.ps1` will take care of them,
   but **you should review its contents before running.**

   > You must use an elevated/Administrator Windows PowerShell 5.1 prompt for
   > this command, PowerShell 7 is not supported at this time.

    ```ps1
    .\init.ps1 -InitEnv -LicenseXmlPath "C:\path\to\license.xml" -AdminPassword "DesiredAdminPassword" -Topology xp0
    ```
    The ```-Topology ``` parameter specify topology you need. This parameter is optional. The default value ```xp0```

    If you check your `.env` into source control, other developers
    can prepare a certificate and hosts file entries by simply running:

    ```ps1
    .\init.ps1
    ```

    > Out of the box, this example does not include `.env` in the `.gitignore`.
    > Individual users may override values using process or system environment variables.
    > This file does contain passwords that would provide access to the running containers
    > in the developer's environment. If your Sitecore solution and/or its data are sensitive,
    > you may want to exclude these from source control and provide another
    > means of centrally configuring the information within. 
    > <br/><br/> **Add** `SERVICE_ISOLATION`=**hyperv** in your **.env** file

1. If this is your first time using `mkcert` with NodeJs, you will
   need to set the `NODE_EXTRA_CA_CERTS` environment variable. This variable
   must be set in your user or system environment variables. The `init.ps1`
   script will provide instructions on how to do this.
    * Be sure to restart your terminal or VS Code for the environment variable
      to take effect.

1. After completing this environment preparation, run the startup script
   from the solution root:
    ```ps1
    .\up.ps1
    ```
     or you can use
    ```ps1
    .\start-clean-install.ps1 -Topology xp0
    ```
    The ```-Topology ``` parameter specify topology you need. This parameter is required. The default value ```xp0```, <br/><br/>The same ```Topology ``` parameter passed to `up.ps1` internally. 

    This script will always start as `FRESH` installation and internally
     * Stop all containers
     * Docker Prune -Remove 
     * Stop IIS, Stop/Start Host Network Service (HNS) 
     * Run .\clean.ps1 
     * Restore Sitecore CLI Tool 
     * Run .\up.ps1 <br/><br/>


1. When prompted, log into Sitecore via your browser, and
   accept the device authorization.

1. Wait for the startup script to open browser tabs for the rendered site
   and Sitecore Launchpad.

## Using the Solution
* A Visual Studio / MSBuild publish of the `Platform` project will update the running `cm` service.
* The running `rendering` service uses `next dev` against the mounted Next.js application, and will recompile automatically for any changes you make.
* You can also run the Next.js application directly using `npm` commands within `src\rendering`.
* Debugging of the Next.js application is possible by using the `start:connected` or `start` scripts from the Next.js `package.json`, and the pre-configured *Attach to Process* VS Code launch configuration.
* Review README's found in the projects and throughout the solution for additional information.
