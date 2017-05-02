define :gunicorn_web_app do
  deploy = params[:deploy]
  application = params[:application]

  nginx_web_app deploy[:application] do
    name application
    application application
    docroot deploy[:absolute_document_root]
    server_name deploy[:domains].first if deploy[:domains]
    server_aliases deploy[:domains][1, deploy[:domains].size] unless deploy[:domains][1, deploy[:domains].size].empty?
    mounted_at deploy[:mounted_at]
    ssl_certificate_ca deploy[:ssl_certificate_ca]
    cookbook "gunicorn"
    deploy deploy
    template "nginx_gunicorn_web_app.erb"
    application deploy
  end
end
