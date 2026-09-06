# Using the Kiro CLI
## Overview
The [Kiro CLI](https://kiro.dev/docs/cli/)  allows you to use Kiro agents in your favorite terminal to build powerful features, analyze errors, suggest fixes, and automate workflows in seconds.

Key features include:

- Prompt to code to deployment in your terminal.
- Build features in complex codebases.
- Automate workflows in seconds.
- Analyze errors and trace bugs with precision.
- Use Kiro CLI to format code, run tests, manage logs, and more - all through automated shell commands.
- Use [custom agents](https://kiro.dev/docs/cli/custom-agents/) in a highly interactive terminal experience.
Use your [knowledge base](https://kiro.dev/docs/cli/experimental/knowledge-management/), [steering files](https://kiro.dev/docs/cli/steering/), and [MCP tools](https://kiro.dev/docs/cli/mcp/), to deliver production-grade code, documentation, and tests that match your requirements.
[Build task-specific custom agents](https://kiro.dev/docs/cli/custom-agents/creating/) optimized for your best practices through pre-defined tool permissions, context, and prompts.
## Authenticating to Kiro CLI
Before using the Kiro CLI, authenticate with your AWS Builder ID.

Run the following command in the IDE terminal:
`kiro-cli login --use-device-flow`

For Select login method, choose Use for Free with Builder ID.
Holding the Command key (Mac) or Control key (Windows), select the URL. Choose Open to open a new browser tab.
For Authorization requested, choose Confirm and continue.
Note
If you did not use the Builder ID to connect to the workshop, or do not have one already set up, follow the prompts to configure a new Builder ID.

Choose Allow access.

The window will show Request approved. Close the tab and return back to your terminal.

Test you are connected using the following command:

`kiro-cli whoami`

Using Kiro CLI
After authenticating with kiro-cli login, start an interactive chat session:

`kiro-cli chat`

This command initiates an interactive chat session with the Kiro CLI in your terminal. You can ask questions, request code samples, troubleshoot issues, and even have Kiro CLI execute commands on your behalf.

When Kiro CLI needs to execute a command on your system, it will prompt you for permission. You have three response options:

y (yes): Allow Kiro CLI to execute the command once.
n (no): Deny execution of the command.
t (trust): Allow Kiro CLI to execute this and similar commands without asking again during the current session.
Best practices for using Kiro CLI
See all supported commands by running kiro-cli --help-all.

When interacting with Kiro CLI, best practices include:

Be specific in your prompt.
Include relevant code snippets for context.
By incorporating Kiro CLI into your development workflow, you can proactively identify and address security vulnerabilities before they make it into production.

Summary
You have learnt a little about Kiro CLI capabilities and ways of leveraging it. You are now ready to start the labs!

