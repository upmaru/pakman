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
    :name
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
    :service,
    Path.join(@prefix, "service.eex"),
    [
      :name
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
