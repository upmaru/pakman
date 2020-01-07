defmodule Pakman.Templates do
  require EEx

  EEx.function_from_file(:def, :apkbuild, "lib/pakman/templates/apkbuild.eex", [
    :name,
    :version,
    :build,
    :depends,
    :makedepends
  ])

  EEx.function_from_file(:def, :initd, "lib/pakman/templates/initd.eex", [
    :name
  ])

  EEx.function_from_file(:def, :profile, "lib/pakman/templates/profile.eex", [
    :name
  ])

  EEx.function_from_file(:def, :service, "lib/pakman/templates/service.eex", [
    :name
  ])

  EEx.function_from_file(:def, :pre_install, "lib/pakman/templates/pre_install.eex", [
    :name
  ])

  EEx.function_from_file(:def, :post_install, "lib/pakman/templates/post_install.eex", [
    :name
  ])

  EEx.function_from_file(:def, :post_upgrade, "lib/pakman/templates/post_upgrade.eex", [
    :name
  ])

  EEx.function_from_file(:def, :pre_deinstall, "lib/pakman/templates/pre_deinstall.eex", [
    :name
  ])
end
