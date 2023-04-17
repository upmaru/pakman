defmodule Pakman.Bootstrap.Templates do
  require EEx

  @prefix "lib/pakman/templates/bootstrap"

  EEx.function_from_file(
    :def,
    :apkbuild,
    Path.join(@prefix, "apkbuild.eex"),
    [
      :name,
      :version,
      :build,
      :configuration
    ]
  )

  EEx.function_from_file(:def, :initd, Path.join(@prefix, "initd.eex"), [
    :configuration
  ])

  EEx.function_from_file(
    :def,
    :profile,
    Path.join(@prefix, "profile.eex"),
    [
      :name
    ]
  )

  EEx.function_from_file(
    :def,
    :environment,
    Path.join(@prefix, "environment.eex"),
    [
      :name
    ]
  )

  EEx.function_from_file(
    :def,
    :env_exec,
    Path.join(@prefix, "env_exec.eex"),
    [
      :name
    ]
  )

  EEx.function_from_file(
    :def,
    :run,
    Path.join(@prefix, "run.eex"),
    [
      :configuration
    ]
  )

  EEx.function_from_file(
    :def,
    :pre_install,
    Path.join(@prefix, "pre_install.eex"),
    [
      :name
    ]
  )

  EEx.function_from_file(:def, :hook, Path.join(@prefix, "hook.eex"), [
    :content
  ])
end
