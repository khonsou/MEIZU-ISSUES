# Redmine - project management software
# Copyright (C) 2006-2012  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class FilesController < ApplicationController
  default_search_scope :attachments
  menu_item :files

  before_filter :find_project_by_project_id
  before_filter :authorize, :except => :upload

  def index
    @attachments = @project.attachments
    @attachments.map(&:push_notifications).flatten.each { |pn| pn.mark_as_read(User.current) }
    
    render :layout => !request.xhr?
  end

  def create
    attachments = Attachment.attach_files(@project, params[:attachments])

    if !attachments.empty? && !attachments[:files].blank?
      attachments[:files].each do |attachment|
        PushNotification::AttachmentNotification.notify(attachment, 'upload')
      end

      Mailer.delay.attachments_added(attachments[:files])
    end

    @attachments = @project.attachments    
    
  end
  
  def upload
    attachments = Attachment.attach_files(@project, params[:attachments])

    if !attachments.empty? && !attachments[:files].blank?
      attachments[:files].each do |attachment|
        PushNotification::AttachmentNotification.notify(attachment, 'upload')
      end

      Mailer.delay.attachments_added(attachments[:files])
    end
    
    if attachments[:files].present?
      render :json => {:attachment_token => attachments[:files].first.token}  
    else
      render :json => {:error => true}
    end    
    
  end
  
end
