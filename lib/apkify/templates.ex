defmodule Apkify.Templates do
  require EEx

  EEx.function_from_file(:def, :apkbuild, "lib/apkify/templates/apkbuild.eex", [
    :name,
    :version,
    :build
  ])
end
