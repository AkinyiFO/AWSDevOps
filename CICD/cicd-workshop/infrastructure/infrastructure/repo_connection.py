from constructs import Construct
from aws_cdk import (
    CfnOutput,
    aws_codecommit as codecommit,
    aws_codepipeline as codepipeline,
    aws_codepipeline_actions as codepipeline_actions,
)

REPOSITORY_NAME = "cicd-workshop"


class RepoConnection:

    def __init__(self, scope: Construct) -> None:
        self.repository = codecommit.Repository.from_repository_name(
            scope,
            "CICD_Workshop",
            REPOSITORY_NAME,
        )

        CfnOutput(scope, "SourceRepositoryName", value=self.repository.repository_name)

        CfnOutput(
            scope,
            "SourceRepositoryCloneUrl",
            value=self.repository.repository_clone_url_grc,
        )

    def source_action(
        self, output: codepipeline.Artifact
    ) -> codepipeline_actions.CodeCommitSourceAction:
        return codepipeline_actions.CodeCommitSourceAction(
            action_name="CodeCommit",
            repository=self.repository,
            output=output,
            branch="main",
        )
