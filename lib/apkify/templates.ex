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
end
