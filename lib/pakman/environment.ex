defmodule Pakman.Environment do
  def branch do
    String.replace(~s(GITHUB_REF), "refs/heads/", "")
  end

  def repository do
    [organization, name] =
      ~s(GITHUB_REPOSITORY)
      |> System.get_env()
      |> String.split("/")

    %{
      organization: Slug.slugify(organization),
      name: name,
      slug: Slug.slugify(name)
    }
  end
end
