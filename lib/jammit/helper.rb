module Jammit

  # The Jammit::Helper module, which is made available to every view, provides
  # helpers for writing out HTML tags for asset packages. In development you
  # get the ordered list of source files -- in any other environment, a link
  # to the cached packages.
  module Helper

    DATA_URI_START = "<!--[if (!IE)|(gte IE 8)]><!-->"
    DATA_URI_END   = "<!--<![endif]-->"
    MHTML_START    = "<!--[if lte IE 7]>"
    MHTML_END      = "<![endif]-->"

    # If embed_images is turned on, writes out links to the Data-URI and MHTML
    # versions of the stylesheet package, otherwise the package is regular
    # compressed CSS, and in development the stylesheet URLs are passed verbatim.
    def include_stylesheets(*packages)
      return individual_stylesheets(packages) unless Jammit.package_assets
      return embedded_image_stylesheets(packages) if Jammit.embed_images
      return packaged_stylesheets(packages)
    end

    # Writes out the URL to the bundled and compressed javascript package,
    # except in development, where it references the individual scripts.
    def include_javascripts(*packages)
      tags = packages.map do |pack|
        Jammit.package_assets ? Jammit.asset_url(pack, :js) : Jammit.packager.individual_urls(pack.to_sym, :js)
      end
      javascript_include_tag(tags.flatten)
    end

    # Writes out the URL to the concatenated and compiled JST file -- we always
    # have to pre-process it, even in development.
    def include_templates(*packages)
      javascript_include_tag(packages.map {|pack| Jammit.asset_url(pack, :jst) })
    end

    private

    # HTML tags, in order, for all of the individual stylesheets.
    def individual_stylesheets(packages)
      options = packages.extract_options!
      jammit_packages = packages.map {|p| Jammit.packager.individual_urls(p.to_sym, :css) }.flatten
      jammit_packages.push(options) unless options.empty?
      stylesheet_link_tag(*jammit_packages)
    end

    # HTML tags for the stylesheet packages.
    def packaged_stylesheets(packages)
      options = packages.extract_options!
      jammit_packages = packages.map {|p| Jammit.asset_url(p, :css) }
      jammit_packages.push(options) unless options.empty?
      stylesheet_link_tag(*jammit_packages)
    end

    # HTML tags for the 'datauri', and 'mhtml' versions of the packaged
    # stylesheets, using conditional comments to load the correct variant.
    def embedded_image_stylesheets(packages)
      options = packages.extract_options!
      jammit_packages = packages.map {|p| Jammit.asset_url(p, :css, :datauri) }
      jammit_packages.push(options) unless options.empty?
      css_tags = stylesheet_link_tag(*jammit_packages)
      ie_tags = if Jammit.mhtml_enabled
                  stylesheet_link_tag(*jammit_packages)
                else
                  packaged_stylesheets(packages)
                end
      [DATA_URI_START, css_tags, DATA_URI_END, MHTML_START, ie_tags, MHTML_END].join("\n")
    end

  end

end

# Include the Jammit asset helpers in all views, a-la ApplicationHelper.
::ActionView::Base.send(:include, Jammit::Helper)
