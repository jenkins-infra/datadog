################################################################################################################################################
# Datadog Logs Pipeline
# - Reminder there is only ONE 'datadog_logs_pipeline_order' resource for the whole tenant
# - The 'datadog_logs_integration_pipeline' resource are sparse: it's only imported empty shells
# - For custom logs pipelines parsers, it is recommended to use the UI to comose it (with samples, assistants, etc.) and add the pipeline here
#    as code once finalized to go through review and audit
################################################################################################################################################

resource "datadog_logs_pipeline_order" "custom_order" {
  name = "custom_order"

  # TODO: define each of these pipeline as code here
  pipelines = [
    datadog_logs_integration_pipeline.glog.id,
    datadog_logs_integration_pipeline.core_dns.id,
    datadog_logs_integration_pipeline.datadog_agent.id,
    datadog_logs_integration_pipeline.nginx.id,
    datadog_logs_integration_pipeline.httpd.id,
    datadog_logs_integration_pipeline.mysql.id,
    datadog_logs_integration_pipeline.kube_cluster_autoscaler.id,
    datadog_logs_integration_pipeline.docker.id,
    datadog_logs_integration_pipeline.apache.id, # Yes, there is "Apache" and "Apache HTTPD" in the default Datadog integrations.
    datadog_logs_integration_pipeline.redis.id,
    datadog_logs_custom_pipeline.nginx_artifact_caching_proxy.id,
    datadog_logs_custom_pipeline.all_jenkins_infra_logs.id,
    datadog_logs_custom_pipeline.mirrorbits_logs.id,
  ]
}

resource "datadog_logs_integration_pipeline" "glog" {
  is_enabled = true
}
resource "datadog_logs_integration_pipeline" "core_dns" {
  is_enabled = true
}
resource "datadog_logs_integration_pipeline" "datadog_agent" {
  is_enabled = true
}
resource "datadog_logs_integration_pipeline" "nginx" {
  is_enabled = true
}
resource "datadog_logs_integration_pipeline" "httpd" {
  is_enabled = true
}
resource "datadog_logs_integration_pipeline" "mysql" {
  is_enabled = true
}
resource "datadog_logs_integration_pipeline" "kube_cluster_autoscaler" {
  is_enabled = true
}
resource "datadog_logs_integration_pipeline" "docker" {
  is_enabled = true
}
resource "datadog_logs_integration_pipeline" "apache" {
  is_enabled = true
}
resource "datadog_logs_integration_pipeline" "redis" {
  is_enabled = true
}

## TODO: describe the intent of this pipeline (remap status? Check request caching status? Other?)
resource "datadog_logs_custom_pipeline" "nginx_artifact_caching_proxy" {
  filter {
    query = "source:nginx service:artifact-caching-proxy"
  }
  name       = "Nginx - artifact-caching-proxy-view"
  is_enabled = true

  processor {
    grok_parser {
      is_enabled = true
      name       = "Parsing Nginx logs + ACP cache (hlm)"
      samples = [
        "10.0.30.36 - - [16/May/2023:14:34:24 +0000] \"GET /public/org/jenkins-ci/main/jenkins-war/2.404/jenkins-war-2.404.war HTTP/1.1\" 200 94777217 20.587 \"-\" \"Apache-Maven/3.9.1 (Java 17.0.7; Linux 5.10.176-157.645.amzn2.x86_64)\" \"10.0.0.20\" \"-\" \"-\" \"-\"",
        "2017/09/26 14:36:50 [error] 8409#8409: *317058 \"/usr/share/nginx/html/sql/sql-admin/index.html\" is not found (2: No such file or directory), client: 217.92.148.44, server: localhost, request: \"HEAD http://174.138.82.103:80/sql/sql-admin/ HTTP/1.1\", host: \"174.138.82.103\"",
        "10.244.2.36 - - [22/May/2023:12:55:57 +0000] \"GET /public/org/apache/maven/maven-compat/3.0/maven-compat-3.0.jar.sha1 HTTP/1.1\" 200 40 1.200 \"-\" \"Apache-Maven/3.9.1 (Java 17.0.7; Windows Server 2019 10.0)\" \"20.242.86.255\" \"-\" \"-\" \"-\"",
        "10.244.0.124 - - [22/May/2023:13:09:40 +0000] \"GET /incrementals/org/jenkins-ci/main/jenkins-bom/2.361/jenkins-bom-2.361.pom HTTP/1.1\" 404 91 0.858 \"-\" \"Apache-Maven/3.9.1 (Java 11.0.19; Linux 5.10.0-0.deb10.17-amd64)\" \"164.90.211.131\" \"34.235.175.210:443\" \"404\" \"0.401\"",
        "10.244.2.24 - - [15/May/2023:23:17:18 +0000] \"GET /public/org/apache/maven/plugins/maven-install-plugin/maven-metadata.xml HTTP/1.1\" 200 781 31.540 \"-\" \"Apache-Maven/3.9.1 (Java 11.0.19; Linux 5.15.0-1037-azure)\" \"172.177.134.158\" \"3.93.92.223:443\" \"200\" \"31.541\"",
      ]
      source = "message"

      grok {
        match_rules   = <<-EOT
          access.common %%{_client_ip} %%{_ident} %%{_auth} \[%%{_date_access}\] "(?>%%{_method} |)%%{_url}(?> %%{_version}|)" %%{_status_code} (?>%%{_bytes_written}|-)

          access.combined %%{access.common} (%%{_request_time} )?"%%{_referer}" "%%{_user_agent}" "%%{_x_forwarded_for}" (%%{_upstream_cached}|%%{_upstream_not_cached}).*

          error.format %%{date("yyyy/MM/dd HH:mm:ss"):date_access} \[%%{word:level}\] %%{data:error.message}(, %%{data::keyvalue(": ",",")})?
        EOT
        support_rules = <<-EOT
          _auth %%{notSpace:http.auth:nullIf("-")}
          _bytes_written %%{integer:network.bytes_written}
          _bytes_written_root %%{integer:network_bytes_written}
          _client_ip %%{ipOrHost:network.client.ip}
          _version HTTP\/%%{regex("\\d+\\.\\d+"):http.version}
          _url %%{notSpace:http.url}
          _ident %%{notSpace:http.ident:nullIf("-")}
          _user_agent %%{regex("[^\\\"]*"):http.useragent}
          _referer %%{notSpace:http.referer}
          _status_code %%{integer:http.status_code}
          _method %%{word:http.method}
          _date_access %%{date("dd/MMM/yyyy:HH:mm:ss Z"):date_access}
          _x_forwarded_for %%{regex("[^\\\"]*"):http._x_forwarded_for:nullIf("-")}
          _request_time %%{number:duration:scale(1000000000)}
          _upstream_addr %%{notSpace:cache.upstream_addr}
          _upstream_addr_empty %%{regex("-"):cache.upstream_addr_empty}
          _upstream_status %%{notSpace:cache.upstream_status}
          _upstream_status_empty %%{regex("-"):cache.upstream_status_empty}
          _upstream_response_time %%{notSpace:cache.upstream_response_time}
          _upstream_cached "%%{regex("-")}" "%%{regex("-")}" "%%{boolean("-",""):cache.upstream_cached}
          _upstream_not_cached "%%{notSpace:cache.upstream_addr}" "%%{number:cache.upstream_status}" "%%{number:cache.upstream_response_time}"
        EOT
      }
    }
  }
  processor {
    attribute_remapper {
      is_enabled           = true
      name                 = "Map `client` to `network.client.ip`"
      override_on_conflict = false
      preserve_source      = false
      source_type          = "attribute"
      sources = [
        "client",
      ]
      target        = "network.client.ip"
      target_format = null
      target_type   = "attribute"
    }
  }
  processor {
    grok_parser {
      is_enabled = true
      name       = "Parsing Nginx Error log requests"
      samples = [
        "HEAD http://174.138.82.103:80/sql/sql-admin/ HTTP/1.1",
      ]
      source = "request"

      grok {
        match_rules   = <<-EOT
          request_parsing (?>%%{_method} |)%%{_url}(?> %%{_version}|)
        EOT
        support_rules = <<-EOT
          _method %%{word:http.method}
          _url %%{notSpace:http.url}
          _version HTTP\/%%{regex("\\d+\\.\\d+"):http.version}
        EOT
      }
    }
  }
  processor {
    url_parser {
      is_enabled               = true
      name                     = null
      normalize_ending_slashes = false
      sources = [
        "http.url",
      ]
      target = "http.url_details"
    }
  }
  processor {
    user_agent_parser {
      is_enabled = true
      is_encoded = false
      name       = null
      sources = [
        "http.useragent",
      ]
      target = "http.useragent_details"
    }
  }
  processor {
    date_remapper {
      is_enabled = true
      name       = "Define `date_access` as the official date of the log"
      sources = [
        "date_access",
      ]
    }
  }
  processor {
    category_processor {
      is_enabled = true
      name       = "Categorise status code"
      target     = "http.status_category"

      category {
        name = "OK"

        filter {
          query = "@http.status_code:[200 TO 299]"
        }
      }
      category {
        name = "notice"

        filter {
          query = "@http.status_code:[300 TO 399]"
        }
      }
      category {
        name = "warning"

        filter {
          query = "@http.status_code:[400 TO 499]"
        }
      }
      category {
        name = "error"

        filter {
          query = "@http.status_code:[500 TO 599]"
        }
      }
    }
  }
  processor {
    status_remapper {
      is_enabled = true
      name       = "Define `http.status_category`, `level` as the official status of the log"
      sources = [
        "http.status_category",
        "level",
      ]
    }
  }
  processor {
    string_builder_processor {
      is_enabled         = false
      is_replace_missing = true
      name               = "cached_if_empty: %%{cache.upstream_cached} - in attribute cache.resultCached"
      target             = "cache.resultCached"
      template           = "cached_if_empty: %%{cache.upstream_cached}"
    }
  }
  processor {
    attribute_remapper {
      is_enabled           = true
      name                 = "cachedProcessor"
      override_on_conflict = false
      preserve_source      = true
      source_type          = "attribute"
      sources = [
        "cache.resultCached",
      ]
      target        = "cached"
      target_format = null
      target_type   = "attribute"
    }
  }
  processor {
    attribute_remapper {
      is_enabled           = true
      name                 = "writtenBytesProcessor"
      override_on_conflict = false
      preserve_source      = true
      source_type          = "attribute"
      sources = [
        "network.bytes_written",
      ]
      target        = "written_bytes"
      target_format = "integer"
      target_type   = "attribute"
    }
  }
  processor {
    category_processor {
      is_enabled = true
      name       = "category cached cat processor"
      target     = "cache.cat_chached"

      category {
        name = "cached"

        filter {
          query = "@cache.upstream_cached:true"
        }
      }
      category {
        name = "notcached"

        filter {
          query = "-@cache.upstream_cached:true"
        }
      }
    }
  }
}
## Remap statuses of all logs from jenkins-infra
# TODO: Could be worth remapping per application: accountapp, Jenkins controllers, etc.
resource "datadog_logs_custom_pipeline" "all_jenkins_infra_logs" {
  filter {
    query = "source:*"
  }
  name       = "All logs"
  is_enabled = true

  processor {
    grok_parser {
      is_enabled = true
      name       = "Status Level Remapper"
      samples = [
        "WARNING: Looking up parameter names for public org.kohsuke.stapler.HttpResponse org.jenkinsci.account.AdminUI.doSearch(java.lang.String) throws javax.naming.NamingException; update plugin to a version created with a newer harness",
        "Aug 17, 2024 2:36:18 PM org.kohsuke.stapler.BytecodeReadingParanamer lookupParameterNames",
        "2024-08-16 23:14:56.467:WARN :oejshC.ROOT_war:Handling GET /doSignup : qtp74885833-24: Error while serving http://accounts.jenkins.io/doSignup",
        "INFO: Both error and output logs will be printed to /home/jenkins/agent/remoting",
        "2024-08-17 15:26:05.418+0000 [id=31136]\tWARNING\to.d.j.p.d.t.DatadogWebhookBuildLogic#toJson: Couldn't find a valid commit for pipelineID 'jenkins-Infra-plugin-site-api-generate-data-315256'. GIT_COMMIT environment variable was not found or has invalid SHA1 string:",
      ]
      source = "message"

      grok {
        match_rules   = <<-EOT
          ParsingAccountAppLogForStatus %%{date("yyyy-MM-dd HH:mm:ss.SSS"):date}(.)%%{word:log_status}(.*)
          ParsingJenkinsLogForStatus %%{date("yyyy-MM-dd HH:mm:ss.SSSZ"):date} \[id=%%{integerStr:jenkinsCorrelationId}\].%%{word:log_status}.*
          ParsingFirstWordForStatus %%{word:log_status}: .*
        EOT
        support_rules = ""
      }
    }
  }
  processor {
    status_remapper {
      is_enabled = true
      name       = "CustomStatusRemapper"
      sources = [
        "log_status",
      ]
    }
  }
}
## Remap statuses of all logs from mirrorbits services
resource "datadog_logs_custom_pipeline" "mirrorbits_logs" {
  filter {
    query = "source:mirrorbits"
  }
  name       = "Mirrorbits logs"
  is_enabled = true

  processor {
    grok_parser {
      is_enabled = true
      name       = "Log Level Status Parser"
      samples = [
        "2024/08/17 17:37:43.909 UTC /download/plugins/snakeyaml-api/index.html: MD5 d499f56fc98d7a5fe1e9e3ecce8b4c4f",
        "2024/08/17 18:15:56.500 UTC -> Node updates-jenkins-io-mirrorbits-7c6bd54c84-gbxsh-27545 joined the cluster",
        "2024/08/17 17:53:43.921 UTC HTTP error: write tcp 10.100.4.4:8080->10.100.4.1:36706: write: broken pipe",
        "2024/08/17 18:16:16.409999 REDIRECT 302 \"/current/update-center.actual.json\" ip:89.84.210.161 mirror:westeurope asn:13335 distance:394.04km countries:FR",
        "2024/08/17 18:15:56.839 UTC eastamerica    Up! (305ms)",
      ]
      source = "message"

      grok {
        support_rules = ""
        # IMPORTANT: Escape '%%{}' datadog syntax as it is also Terraform template directive
        # https://developer.hashicorp.com/terraform/language/expressions/strings#escape-sequences-1
        match_rules = <<-EOT
          parseMirrorbitsAccessLog %%%{date("yyyy/MM/dd HH:mm:ss.SSSSSS"):date}\s+%%%{word:request_result}\s+%%%{integer:http_status}\s+"%%%{notSpace:http_uri}"\s+%%%{data::keyvalue(":")}

          parseMirrorbitsScanLog %%%{date("yyyy/MM/dd HH:mm:ss.SSS z"):date}\s+%%%{notSpace:http_uri}:\s+%%%{notSpace:hash_type}\s+%%%{notSpace:hash_value}

          parseMirrorbitsErrorLog %%%{date("yyyy/MM/dd HH:mm:ss.SSS z"):date}\s+HTTP\s+%%%{notSpace:log_status:uppercase}:%%%{data:error_message}

          parseMirrorbitHealthCheck %%%{date("yyyy/MM/dd HH:mm:ss.SSS z"):date}\s+%%%{notSpace:mirror_id}\s+%%%{notSpace:mirror_status}!\s+\(%%%{notSpace:mirror_latency}\)

          parseMirrorNodeEvent %%%{date("yyyy/MM/dd HH:mm:ss.SSS z"):date} -> Node %%%{notSpace:node_id}\s+%%%{data:node_event}
        EOT
      }
    }
  }
  processor {
    category_processor {
      is_enabled = true
      name       = "Define Status"
      target     = "log_level"

      category {
        name = "INFO"

        filter {
          query = "@mirror_status:Up OR @request_result:REDIRECT OR @hash_type:*"
        }
      }
    }
  }
  processor {
    status_remapper {
      is_enabled = true
      name       = "Status Remapper: Custom Status"
      sources = [
        "log_level",
      ]
    }
  }
}
