module NavHelper
  def nav_link_to(name, path, match: :exact, **opts)
    active =
      if match == :starts_with
        request.path.starts_with?(path)
      else
        current_page?(path)
      end

    base = "px-3 py-2 rounded-md text-sm font-medium transition hover:bg-sky-50"
    active_classes = "text-sky-900 underline decoration-2 underline-offset-4"
    inactive_classes = "text-gray-700"

    classes = [ base, (active ? active_classes : inactive_classes), opts.delete(:class) ].compact.join(" ")
    link_to name, path, { class: classes, "aria-current": (active ? "page" : nil) }.merge(opts)
  end

  def role_chip(role)
    color = case role.to_s
    when "owner", "admin" then "bg-red-100 text-red-800"
    when "recruiter"      then "bg-indigo-100 text-indigo-800"
    when "manager"        then "bg-amber-100 text-amber-800"
    when "user"           then "bg-gray-100 text-gray-800"
    else                       "bg-slate-100 text-slate-800"
    end
    content_tag :span, role.to_s.titleize, class: "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium #{color}"
  end

  def avatar_initials(user)
    name = user&.respond_to?(:name) ? user.name.to_s : ""
    initials =
      if name.strip.present?
        name.split(/\s+/).first(2).map { _1[0] }.join
      else
        # fall back to email first letter
        (user&.email.to_s[0] || "?").upcase
      end

    initials
  end
end
