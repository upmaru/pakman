defmodule Apkify.Templates do
  require EEx

  EEx.function_from_file(:def, :apkbuild, "lib/apkify/templates/apkbuild.eex", [
    :name,
    :version,
    :build,
    :depends,
    :makedepends
  ])

  EEx.function_from_file(:def, :initd, "lib/apkify/templates/initd.eex", [
    :name
  ])

  EEx.function_from_file(:def, :profile, "lib/apkify/templates/profile.eex", [
    :name
  ])

  EEx.function_from_file(:def, :service, "lib/apkify/templates/service.eex", [
    :name
  ])

  EEx.function_from_file(:def, :pre_install, "lib/apkify/templates/pre_install.eex", [
    :name
  ])

  EEx.function_from_file(:def, :post_install, "lib/apkify/templates/post_install.eex", [
    :name
  ])

  EEx.function_from_file(:def, :post_upgrade, "lib/apkify/templates/post_upgrade.eex", [
    :name
  ])

  EEx.function_from_file(:def, :pre_deinstall, "lib/apkify/templates/pre_deinstall.eex", [
    :name
  ])
end
