define :gunicorn_web_app do
  deploy = params[:deploy]
  application = params[:application]

  nginx_web_app deploy[:application] do
    docroot deploy[:absolute_document_root]
    server_name deploy[:domains].first if deploy[:domains]
    mounted_at deploy[:mounted_at]
    ssl_certificate_ca deploy[:ssl_certificate_ca]
    cookbook "gunicorn"
    deploy deploy
    template "nginx_gunicorn_web_app.erb"
    application deploy
  end
end
