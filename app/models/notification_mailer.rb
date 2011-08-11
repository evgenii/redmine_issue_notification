require 'ar_condition'

class NotificationMailer < ActionMailer::Base
  layout 'mailer'
  helper :application
  helper :issues
  helper :custom_fields

  include ActionController::UrlWriter
  include Redmine::I18n

  def self.default_url_options
    h = Setting.host_name
    h = h.to_s.gsub(%r{\/.*$}, '') unless Redmine::Utils.relative_url_root.blank?
    { :host => h, :protocol => Setting.protocol }
  end
  
  def notification_reminder(issue, days)
   
   set_language_if_valid Setting.default_language
   recipients issue.get_emails

    @issue_name = "#{issue.project} - #{issue.tracker} ##{issue.id}"
    subject l(:mail_subject_notifier_reminder, :issue => @issue_name, :days => days)
    body :issue => issue, :days => days,
         :issue_url => url_for( :controller => 'issues', :action => 'show', :id => issue.id )
    render_multipart('notification_reminder', body)
  end

  # Overrides default deliver! method to prevent from sending an email
  # with no recipient, cc or bcc
  def deliver!(mail = @mail)
    set_language_if_valid @initial_language
    return false if (recipients.nil? || recipients.empty?) &&
                    (cc.nil? || cc.empty?) &&
                    (bcc.nil? || bcc.empty?)
                    
    # Set Message-Id and References
    if @message_id_object
      mail.message_id = self.class.message_id_for(@message_id_object)
    end
    if @references_objects
      mail.references = @references_objects.collect {|o| self.class.message_id_for(o)}
    end
    
    # Log errors when raise_delivery_errors is set to false, Rails does not
    raise_errors = self.class.raise_delivery_errors
    self.class.raise_delivery_errors = true
    begin
      return super(mail)
    rescue Exception => e
      if raise_errors
        raise e
      elsif mylogger
        mylogger.error "The following error occured while sending email notification: \"#{e.message}\". Check your configuration in config/email.yml."
      end
    ensure
      self.class.raise_delivery_errors = raise_errors
    end
  end

  private
  def initialize_defaults(method_name)
    super
    @initial_language = current_language
    set_language_if_valid Setting.default_language
    from Setting.mail_from
    
    # Common headers
    headers 'X-Mailer' => 'Redmine',
            'X-Redmine-Host' => Setting.host_name,
            'X-Redmine-Site' => Setting.app_title,
            'Precedence' => 'bulk',
            'Auto-Submitted' => 'auto-generated'
  end

  # Appends a Redmine header field (name is prepended with 'X-Redmine-')
  def redmine_headers(h)
    h.each { |k,v| headers["X-Redmine-#{k}"] = v }
  end

  # Overrides the create_mail method
  def create_mail
    # Removes the current user from the recipients and cc
    # if he doesn't want to receive notifications about what he does
    @author ||= User.current
    if @author.pref[:no_self_notified]
      recipients.delete(@author.mail) if recipients
      cc.delete(@author.mail) if cc
    end
    
    notified_users = [recipients, cc].flatten.compact.uniq
    # Rails would log recipients only, not cc and bcc
    mylogger.info "Sending email notification to: #{notified_users.join(', ')}" if mylogger
    
    # Blind carbon copy recipients
    if Setting.bcc_recipients?
      bcc(notified_users)
      recipients []
      cc []
    end
    super
  end

  # Rails 2.3 has problems rendering implicit multipart messages with
  # layouts so this method will wrap an multipart messages with
  # explicit parts.
  #
  # https://rails.lighthouseapp.com/projects/8994/tickets/2338-actionmailer-mailer-views-and-content-type
  # https://rails.lighthouseapp.com/projects/8994/tickets/1799-actionmailer-doesnt-set-template_format-when-rendering-layouts
  
  def render_multipart(method_name, body)
    if Setting.plain_text_mail?
      content_type "text/plain"
      body render(:file => "#{method_name}.text.plain.rhtml", :body => body, :layout => 'mailer.text.plain.erb')
    else
      content_type "multipart/alternative"
      part :content_type => "text/plain", :body => render(:file => "#{method_name}.text.plain.rhtml", :body => body, :layout => 'mailer.text.plain.erb')
      part :content_type => "text/html", :body => render_message("#{method_name}.text.html.rhtml", body)
    end
  end

  # Makes partial rendering work with Rails 1.2 (retro-compatibility)
  def self.controller_path
    ''
  end unless respond_to?('controller_path')
  
  # Returns a predictable Message-Id for the given object
  def self.message_id_for(object)
    # id + timestamp should reduce the odds of a collision
    # as far as we don't send multiple emails for the same object
    timestamp = object.send(object.respond_to?(:created_on) ? :created_on : :updated_on) 
    hash = "redmine.#{object.class.name.demodulize.underscore}-#{object.id}.#{timestamp.strftime("%Y%m%d%H%M%S")}"
    host = Setting.mail_from.to_s.gsub(%r{^.*@}, '')
    host = "#{::Socket.gethostname}.redmine" if host.empty?
    "<#{hash}@#{host}>"
  end
  
  private
  
  def message_id(object)
    @message_id_object = object
  end
  
  def references(object)
    @references_objects ||= []
    @references_objects << object
  end
    
  def mylogger
    RAILS_DEFAULT_LOGGER
  end
end

