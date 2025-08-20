workspace "AS-IS Enterprise Architecture" "Current state architecture documentation using C4 model" {

    !identifiers hierarchical

    model {
        # Define people
        user = person "User" "End user accessing the system through web interface"
        
        # Define external systems
        gsn = softwareSystem "Government Services Network (GSN)" "External government agencies and services" {
            tags "External System"
            
            nic = container "NIC" "National Information Center services" "Government Service" {
                tags "External Service"
            }
            
            gosi = container "GOSI" "General Organization for Social Insurance" "Government Service" {
                tags "External Service"
            }
            
            moc = container "MOC" "Ministry of Commerce services" "Government Service" {
                tags "External Service"
            }
            
            mof = container "MOF" "Ministry of Finance services" "Government Service" {
                tags "External Service"
            }
            
            otherAgencies = container "Other Government Agencies" "Additional government service providers" "Government Service" {
                tags "External Service"
            }
        }
        
        thirdParties = softwareSystem "Third Party Systems" "External third-party service providers" {
            tags "External System"
        }
        
        hrsd = softwareSystem "HRSD System" "Human Resources and Social Development system" {
            tags "External System"
            
            hrsdDataPower = container "HRSD DataPower" "HRSD security gateway" "IBM DataPower" {
                tags "External Container"
            }
            
            hrsdDatabase = container "HRSD Database" "HRSD core database" "Oracle" {
                tags "External Database"
            }
            
            hrsdBackend = container "HRSD Backend" "HRSD application services" "Java/.NET" {
                tags "External Service"
            }
        }
        
        # Define main system
        mainSystem = softwareSystem "TIP Integration Platform" "Core integration platform for government services" {
            
            # Frontend containers
            spa = container "Frontend SPA" "Single Page Application for user interface" "React/Angular" {
                tags "Web Browser"
            }
            
            bff = container "Backend For Frontend" "API gateway and aggregation layer for frontend" "Node.js/Java" {
                tags "API"
            }
            
            # IBM Integration Platform containers
            apiConnect = container "IBM API Connect" "API Management and Gateway platform" "IBM API Connect" {
                tags "API Gateway"
                
                apiComponent = component "API Gateway" "Manages API lifecycle and security" "IBM API Connect Runtime"
            }
            
            appConnect = container "IBM App Connect" "Integration and orchestration platform" "IBM App Connect" {
                tags "Integration"
                
                integrationServer = component "Integration Server" "Handles message transformation and routing" "IBM Integration Server"
                appComponent = component "Integration App" "Business logic and workflow orchestration" "IBM App Connect App"
            }
            
            ibmMQ = container "IBM MQ" "Message queuing and reliable messaging" "IBM MQ" {
                tags "Message Queue"
                
                queueManager = component "Queue Manager" "Manages message queues and ensures delivery" "IBM MQ Queue Manager"
            }
            
            ibmODM = container "IBM ODM" "Business rules management and decision engine" "IBM ODM" {
                tags "Business Rules"
                
                ruleServer = component "Rule Server" "Executes business rules and decisions" "IBM ODM Rule Server"
            }
            
            # DMZ Security Layer
            dataPower = container "DataPower Gateway" "Security gateway and transformation appliance" "IBM DataPower" {
                tags "Security Gateway"
            }
            
            # Database containers
            qiwaDB = container "QIWA Database" "Core business data storage" "Oracle/PostgreSQL" {
                tags "Database"
            }
            
            hrsdReplica = container "HRSD Replica Database" "Replicated HRSD data for performance" "Oracle/PostgreSQL" {
                tags "Database"
            }
            
            paymentsDB = container "Payments Database" "Payment transactions and records" "Oracle/PostgreSQL" {
                tags "Database"
            }
        }
        
        # Define relationships
        # C1 Level relationships
        user -> mainSystem "Uses" "HTTPS"
        mainSystem -> gsn "Integrates with" "HTTPS"
        mainSystem -> thirdParties "Connects to" "HTTPS"
        mainSystem -> hrsd "Synchronizes with" "HTTPS/ODBC"
        
        # C2 Level relationships
        user -> mainSystem.spa "Accesses" "HTTPS"
        mainSystem.spa -> mainSystem.bff "Calls" "HTTPS/REST"
        mainSystem.bff -> mainSystem.apiConnect "Routes through" "HTTPS/REST"
        mainSystem.apiConnect -> mainSystem.appConnect "Orchestrates via" "HTTPS"
        mainSystem.appConnect -> mainSystem.ibmMQ "Publishes to" "AMQP"
        mainSystem.appConnect -> mainSystem.ibmODM "Evaluates rules via" "HTTPS"
        mainSystem.appConnect -> mainSystem.qiwaDB "Reads/writes" "ODBC/JDBC"
        mainSystem.appConnect -> mainSystem.hrsdReplica "Reads from" "ODBC/JDBC"
        mainSystem.appConnect -> mainSystem.paymentsDB "Manages" "ODBC/JDBC"
        mainSystem.appConnect -> mainSystem.dataPower "Secure calls via" "HTTPS"
        
        mainSystem.dataPower -> hrsd.hrsdDataPower "Communicates with" "HTTPS"
        hrsd.hrsdDataPower -> hrsd.hrsdBackend "Invokes" "HTTPS"
        hrsd.hrsdDataPower -> hrsd.hrsdDatabase "Queries" "ODBC"
        hrsd.hrsdDataPower -> gsn.nic "Calls" "HTTPS"
        hrsd.hrsdDataPower -> gsn.gosi "Calls" "HTTPS"
        hrsd.hrsdDataPower -> gsn.moc "Calls" "HTTPS"
        hrsd.hrsdDataPower -> gsn.mof "Calls" "HTTPS"
        hrsd.hrsdDataPower -> gsn.otherAgencies "Calls" "HTTPS"
        
        hrsd.hrsdDatabase -> mainSystem.dataPower "Replicates to" "ODBC"
        mainSystem.dataPower -> mainSystem.hrsdReplica "Updates" "ODBC"
        mainSystem.dataPower -> thirdParties "Integrates with" "HTTPS"
        
        # C3 Level relationships (Component level)
        mainSystem.apiConnect.apiComponent -> mainSystem.appConnect.integrationServer "Routes to" "HTTPS"
        mainSystem.appConnect.integrationServer -> mainSystem.appConnect.appComponent "Executes" "Internal"
        mainSystem.appConnect.integrationServer -> mainSystem.ibmMQ.queueManager "Sends messages to" "AMQP"
        mainSystem.appConnect.integrationServer -> mainSystem.ibmODM.ruleServer "Evaluates via" "HTTPS"
    }
    
    views {
        # C1 - System Context Diagram
        systemContext mainSystem "SystemContext" {
            include *
            autolayout lr
            title "C1 - System Context: TIP Integration Platform"
            description "High-level view of the TIP Integration Platform and its relationships with users and external systems"
        }
        
        # C2 - Container Diagram
        container mainSystem "Containers" {
            include *
            autolayout lr
            title "C2 - Container Diagram: TIP Integration Platform"
            description "Container-level view showing the internal structure of the TIP Integration Platform"
        }
        
        # C3 - Component Diagrams
        component mainSystem.apiConnect "APIConnectComponents" {
            include *
            autolayout lr
            title "C3 - Component Diagram: IBM API Connect"
            description "Component-level view of IBM API Connect container"
        }
        
        component mainSystem.appConnect "AppConnectComponents" {
            include *
            autolayout lr
            title "C3 - Component Diagram: IBM App Connect"
            description "Component-level view of IBM App Connect container showing integration components"
        }
        
        component mainSystem.ibmMQ "IBMMQComponents" {
            include *
            autolayout lr
            title "C3 - Component Diagram: IBM MQ"
            description "Component-level view of IBM MQ container showing messaging components"
        }
        
        component mainSystem.ibmODM "IBMODMComponents" {
            include *
            autolayout lr
            title "C3 - Component Diagram: IBM ODM"
            description "Component-level view of IBM ODM container showing business rules components"
        }
        
        # Dynamic diagrams for key flows
        dynamic mainSystem "UserJourney" "User Authentication and Service Request Flow" {
            user -> mainSystem.spa "1. Access application"
            mainSystem.spa -> mainSystem.bff "2. API request"
            mainSystem.bff -> mainSystem.apiConnect "3. Route to API gateway"
            mainSystem.apiConnect -> mainSystem.appConnect "4. Process integration"
            mainSystem.appConnect -> mainSystem.ibmMQ "5. Queue message"
            mainSystem.appConnect -> mainSystem.ibmODM "6. Apply business rules"
            mainSystem.appConnect -> mainSystem.dataPower "7. External service call"
            mainSystem.dataPower -> hrsd "8. HRSD integration"
            autolayout lr
        }
        
        styles {
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            element "Web Browser" {
                shape WebBrowser
                background #85bbf0
            }
            element "API" {
                background #7FAD33
            }
            element "API Gateway" {
                background #FF6B35
            }
            element "Integration" {
                background #8E44AD
                color #ffffff
            }
            element "Message Queue" {
                background #E67E22
                color #ffffff
            }
            element "Business Rules" {
                background #2ECC71
                color #ffffff
            }
            element "Security Gateway" {
                background #E74C3C
                color #ffffff
            }
            element "Database" {
                shape Cylinder
                background #3498DB
                color #ffffff
            }
            element "External Container" {
                background #CCCCCC
            }
            element "External Database" {
                shape Cylinder
                background #AAAAAA
            }
            element "External Service" {
                background #BBBBBB
            }
        }
    }
}