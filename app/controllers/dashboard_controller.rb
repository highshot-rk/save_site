class DashboardController < ApplicationController
  require 'uri'
  require 'net/http'

  def index
  end

  def save_content
    paras = params[:query]
    metadata = params[:metadata]

    results = []

    Dir.mkdir(Rails.root.join('fetch')) unless File.exists?(Rails.root.join('fetch'))
    if paras.nil? || paras.empty?
        results = [{
            url: nil,
            msg: 'Please input urls'
        }]
    else
        queries = paras.strip.split(/\s+/)
        queries.each do |query|
            uri = URI(query.strip)
            begin
                res = Net::HTTP.get_response(uri)
                case res
                when Net::HTTPSuccess
                    content = res.body
                    File.open("#{Rails.root.join('fetch', [uri.hostname, uri.path].join.delete("/") + '.html')}", 'w') { |file| file.write(content) }
                    
                    if metadata == "1"
                        results.append({
                            url: query.strip,
                            site: [uri.hostname, uri.path].join.delete("/"),
                            num_links: content.scan("http://").count + content.scan("https://").count,
                            images: content.scan("<img").count + content.scan("type=\"image").count,
                            last_fetch: Time.now.strftime("%d/%m/%Y %H:%M"),
                            msg: 'sucess'
                        })
                    else
                        results.append({
                            url: query.strip,
                            msg: 'sucess'
                        })
                    end
                else
                    results.append({
                        url: query.strip,
                        msg: 'error'
                    })
                end
            rescue StandardError => e
                results = [{
                    url: query.strip,
                    msg: 'Please input exact url'
                }]
            end
        end

    end
    flash[:results] = results
    render action: "index"
  end
  
end
