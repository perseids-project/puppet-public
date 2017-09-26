class sosol::alpheios {
  $data_dir = '/usr/local/docker-existdb/alpheios'
  $cts_api_url = hiera('sosol::cts_api_url')
  $alignment_editor_url = hiera('sosol::alignment_editor_url')
  $edit_utils_url = hiera('sosol::edit_utils_url')

  file{ $data_dir:
    ensure => directory,
    owner  => 'deployer',
    group  => 'deployer',
  }

  archive{ "${data_dir}/cts-api.zip":
    source  => $cts_api_url,
    extract => false,
  }

  archive{ "${data_dir}/alignment-editor.zip":
    source  => $alignment_editor_url,
    extract => false,
  }

  archive{ "${data_dir}/edit-utils.zip":
    source  => $edit_utils_url,
    extract => false,
  }
}
