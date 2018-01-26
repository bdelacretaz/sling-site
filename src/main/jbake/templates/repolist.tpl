// ------------------------------------------------------------------------------------------------
// Sling 'repolist' page - list of GitHub repositories generated from an XML file
// that our pom downloads.
// ------------------------------------------------------------------------------------------------

// Include common utilities
U = new includes.U(config)

layout 'layout/main.tpl', true,
    projects: projects,
    tags : contents {
        include template: 'tags-brick.tpl'
    },
    bodyContents: contents {
        section(class:"wrap"){
            yieldUnescaped U.processBody(content, config)
        }
        
        def filename = "${config.repolist_path}"
        def file = new File(filename)
        def repos = new XmlSlurper().parse(file)
        def NOGROUP = "<NO GROUP SET>"
        Set groups = []

        // Get the groups
        repos.'**'.findAll { 
            node -> 
            node.name() == 'project' }*.each() {
                p ->
                def group = p.attributes().groups
                if(group) {
                    groups.add(group)
                }
            }

        // Sort and add ungrouped projects to the end
        groups=groups.toSorted()
        groups.add(NOGROUP)

        // List projects by group
        groups.each() {
            group ->
            h2() { 
                yield("Group: ${group}")
            }
            
            ul() {
                repos.'**'.findAll { 
                    node -> 
                    node.name() == 'project' && (node.attributes().groups == group || group == NOGROUP &&   !node.attributes().hasProperty('groups'))
                }*.each() {
                    p -> 
                    li() {
                        a(href:"${config.sling_github_baseURL}${p.attributes().name}") {
                            yield("${p.attributes().path}")
                        }
                    }
                }
            }
    
        }
    }
