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

require "sqlite3"

  def db_insert_releases(db, org, repo, releases)
    releases.each do |release|
        db.execute(
         "DELETE FROM releases WHERE org=? AND repo=? AND id=?", [org, repo, release.id] )

        # Sometimes there is no author. Instead, fill in the data with the first file's uploader
        if(release.author)
            author=release.author.login
        else
            if(release.assets and release.assets[0] and release.assets[0].uploader)
                author=release.assets[0].uploader.login
#                puts "Unable to find an author for #{release.html_url}; using uploader: #{author}"
            else
                author=nil
#                puts "Unable to find an author or uploader for #{release.html_url}"
            end
        end


        db.execute(
         "INSERT INTO releases (
            org, repo, id, html_url, tarball_url, zipball_url, tag_name, name, body, created_at, published_at, author
          )
          VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )",
          [ org, repo, release.id, release.html_url, release.tarball_url, release.zipball_url, release.tag_name, release.name, release.body, release.created_at.to_s, release.published_at.to_s, author] )
    end
  end

def sync_releases(feedback, dashboard_config, client, sync_db)
  
  organizations = dashboard_config['organizations']
  feedback.puts " releases"
  
  organizations.each do |org|
    sync_db.execute("BEGIN TRANSACTION");
    feedback.print "  #{org} "

    # There's no @since here, so it's removing current data and replacing with all release info from GitHub
    # Could use this for initial load and use the event data stream for updates
    client.organization_repositories(org).each do |repo_obj|
      releases=client.releases(repo_obj.full_name)
      db_insert_releases(sync_db, org, repo_obj.name, releases)   # Replaces existing with these
      feedback.print '.'
    end
    sync_db.execute("END TRANSACTION");

    feedback.print "\n"
  end

end
