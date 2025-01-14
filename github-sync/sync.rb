# Copyright 2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rubygems'
require 'octokit'
require 'date'
require 'yaml'

require_relative 'db_metadata/sync-metadata.rb'
require_relative 'db_commits/sync-commits.rb'
require_relative 'db_events/sync-events.rb'
require_relative 'db_issues/sync-issues.rb'
require_relative 'db_releases/sync-releases.rb'
require_relative 'user_mapping/sync-users.rb'
require_relative 'reporting/db_reporter_runner.rb'

def github_sync(feedback, dashboard_config, client, run_one)

  db_filename=File.join(dashboard_config['data-directory'], 'db', 'gh-sync.db');

  sync_db=SQLite3::Database.new db_filename

  if(not(run_one) or run_one=='github-sync/metadata')
    sync_metadata(feedback, dashboard_config, client, sync_db)
  end
  if(not(run_one) or run_one=='github-sync/commits')
    sync_commits(feedback, dashboard_config, client, sync_db)
  end
  if(not(run_one) or run_one=='github-sync/events')
    sync_events(feedback, dashboard_config, client, sync_db)
  end
  if(not(run_one) or run_one=='github-sync/issues')
    sync_issues(feedback, dashboard_config, client, sync_db)
  end
  if(not(run_one) or run_one=='github-sync/releases')
    sync_releases(feedback, dashboard_config, client, sync_db)
  end
  if(not(run_one) or run_one=='github-sync/user-mapping')
    sync_user_mapping(feedback, dashboard_config, client, sync_db)
  end
  if(not(run_one) or run_one=='github-sync/reporting')
    run_db_reports(feedback, dashboard_config, client, sync_db)
  end

  sync_db.close

end

