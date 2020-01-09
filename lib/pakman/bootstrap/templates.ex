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
      :depends,
      :makedepends
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

  EEx.function_from_file(
    :def,
    :post_install,
    Path.join(@prefix, "post_install.eex"),
    [
      :name
    ]
  )

  EEx.function_from_file(
    :def,
    :post_upgrade,
    Path.join(@prefix, "post_upgrade.eex"),
    [
      :name
    ]
  )

  EEx.function_from_file(
    :def,
    :pre_deinstall,
    Path.join(@prefix, "pre_deinstall.eex"),
    [
      :name
    ]
  )
end
