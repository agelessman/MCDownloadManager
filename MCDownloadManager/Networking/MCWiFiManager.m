//
//  MCWiFiManager.m
//  MCDownloadManager
//
//  Created by 马超 on 16/9/14.
//  Copyright © 2016年 qikeyun. All rights reserved.
//



#import "MCWiFiManager.h"
#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <arpa/inet.h>
#import <netinet/in.h>
#import <ifaddrs.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <netinet/in.h>
#include <sys/param.h>



/*
 * Copyright (c) 2000-2008 Apple Inc. All rights reserved.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. The rights granted to you under the License
 * may not be used to create, or enable the creation or redistribution of,
 * unlawful or unlicensed copies of an Apple operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any
 * terms of an Apple operating system software license agreement.
 *
 * Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_END@
 */
/*
 * Copyright (c) 1980, 1986, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *	@(#)route.h	8.3 (Berkeley) 4/19/94
 * $FreeBSD: src/sys/net/route.h,v 1.36.2.1 2000/08/16 06:14:23 jayanth Exp $
 */
#ifndef TARGET_IPHONE_SIMULATOR

#ifndef _NET_ROUTE_H_
#define _NET_ROUTE_H_
#include <sys/appleapiopts.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/socket.h>

/*
 * Kernel resident routing tables.
 *
 * The routing tables are initialized when interface addresses
 * are set by making entries for all directly connected interfaces.
 */

/*
 * A route consists of a destination address and a reference
 * to a routing entry.  These are often held by protocols
 * in their control blocks, e.g. inpcb.
 */
struct route;


/*
 * These numbers are used by reliable protocols for determining
 * retransmission behavior and are included in the routing structure.
 */
struct rt_metrics {
    u_int32_t	rmx_locks;	/* Kernel must leave these values alone */
    u_int32_t	rmx_mtu;	/* MTU for this path */
    u_int32_t	rmx_hopcount;	/* max hops expected */
    int32_t		rmx_expire;	/* lifetime for route, e.g. redirect */
    u_int32_t	rmx_recvpipe;	/* inbound delay-bandwidth product */
    u_int32_t	rmx_sendpipe;	/* outbound delay-bandwidth product */
    u_int32_t	rmx_ssthresh;	/* outbound gateway buffer limit */
    u_int32_t	rmx_rtt;	/* estimated round trip time */
    u_int32_t	rmx_rttvar;	/* estimated rtt variance */
    u_int32_t	rmx_pksent;	/* packets sent using this route */
    u_int32_t	rmx_filler[4];	/* will be used for T/TCP later */
};



/*
 * rmx_rtt and rmx_rttvar are stored as microseconds;
 */
#define	RTM_RTTUNIT	1000000	/* units for rtt, rttvar, as units per sec */

/*
 * We distinguish between routes to hosts and routes to networks,
 * preferring the former if available.  For each route we infer
 * the interface to use from the gateway address supplied when
 * the route was entered.  Routes that forward packets through
 * gateways are marked so that the output routines know to address the
 * gateway rather than the ultimate destination.
 */


#define	RTF_UP		0x1		/* route usable */
#define	RTF_GATEWAY	0x2		/* destination is a gateway */
#define	RTF_HOST	0x4		/* host entry (net otherwise) */
#define	RTF_REJECT	0x8		/* host or net unreachable */
#define	RTF_DYNAMIC	0x10		/* created dynamically (by redirect) */
#define	RTF_MODIFIED	0x20		/* modified dynamically (by redirect) */
#define RTF_DONE	0x40		/* message confirmed */
#define RTF_DELCLONE	0x80		/* delete cloned route */
#define RTF_CLONING	0x100		/* generate new routes on use */
#define RTF_XRESOLVE	0x200		/* external daemon resolves name */
#define RTF_LLINFO	0x400		/* generated by link layer (e.g. ARP) */
#define RTF_STATIC	0x800		/* manually added */
#define RTF_BLACKHOLE	0x1000		/* just discard pkts (during updates) */
#define RTF_PROTO2	0x4000		/* protocol specific routing flag */
#define RTF_PROTO1	0x8000		/* protocol specific routing flag */

#define RTF_PRCLONING	0x10000		/* protocol requires cloning */
#define RTF_WASCLONED	0x20000		/* route generated through cloning */
#define RTF_PROTO3	0x40000		/* protocol specific routing flag */
/* 0x80000 unused */
#define RTF_PINNED	0x100000	/* future use */
#define	RTF_LOCAL	0x200000	/* route represents a local address */
#define	RTF_BROADCAST	0x400000	/* route represents a bcast address */
#define	RTF_MULTICAST	0x800000	/* route represents a mcast address */
#define RTF_IFSCOPE	0x1000000	/* has valid interface scope */
#define RTF_CONDEMNED	0x2000000	/* defunct; no longer modifiable */
/* 0x4000000 and up unassigned */

/*
 * Routing statistics.
 */
struct	rtstat {
    short	rts_badredirect;	/* bogus redirect calls */
    short	rts_dynamic;		/* routes created by redirects */
    short	rts_newgateway;		/* routes modified by redirects */
    short	rts_unreach;		/* lookups which failed */
    short	rts_wildcard;		/* lookups satisfied by a wildcard */
};

/*
 * Structures for routing messages.
 */
struct rt_msghdr {
    u_short	rtm_msglen;		/* to skip over non-understood messages */
    u_char	rtm_version;		/* future binary compatibility */
    u_char	rtm_type;		/* message type */
    u_short	rtm_index;		/* index for associated ifp */
    int	rtm_flags;		/* flags, incl. kern & message, e.g. DONE */
    int	rtm_addrs;		/* bitmask identifying sockaddrs in msg */
    pid_t	rtm_pid;		/* identify sender */
    int	rtm_seq;		/* for sender to identify action */
    int	rtm_errno;		/* why failed */
    int	rtm_use;		/* from rtentry */
    u_int32_t rtm_inits;		/* which metrics we are initializing */
    struct rt_metrics rtm_rmx;	/* metrics themselves */
};

struct rt_msghdr2 {
    u_short	rtm_msglen;		/* to skip over non-understood messages */
    u_char	rtm_version;		/* future binary compatibility */
    u_char	rtm_type;		/* message type */
    u_short	rtm_index;		/* index for associated ifp */
    int	rtm_flags;		/* flags, incl. kern & message, e.g. DONE */
    int	rtm_addrs;		/* bitmask identifying sockaddrs in msg */
    int32_t	rtm_refcnt;		/* reference count */
    int	rtm_parentflags;	/* flags of the parent route */
    int	rtm_reserved;		/* reserved field set to 0 */
    int	rtm_use;		/* from rtentry */
    u_int32_t rtm_inits;		/* which metrics we are initializing */
    struct rt_metrics rtm_rmx;	/* metrics themselves */
};


#define RTM_VERSION	5	/* Up the ante and ignore older versions */

/*
 * Message types.
 */
#define RTM_ADD		0x1	/* Add Route */
#define RTM_DELETE	0x2	/* Delete Route */
#define RTM_CHANGE	0x3	/* Change Metrics or flags */
#define RTM_GET		0x4	/* Report Metrics */
#define RTM_LOSING	0x5	/* Kernel Suspects Partitioning */
#define RTM_REDIRECT	0x6	/* Told to use different route */
#define RTM_MISS	0x7	/* Lookup failed on this address */
#define RTM_LOCK	0x8	/* fix specified metrics */
#define RTM_OLDADD	0x9	/* caused by SIOCADDRT */
#define RTM_OLDDEL	0xa	/* caused by SIOCDELRT */
#define RTM_RESOLVE	0xb	/* req to resolve dst to LL addr */
#define RTM_NEWADDR	0xc	/* address being added to iface */
#define RTM_DELADDR	0xd	/* address being removed from iface */
#define RTM_IFINFO	0xe	/* iface going up/down etc. */
#define	RTM_NEWMADDR	0xf	/* mcast group membership being added to if */
#define	RTM_DELMADDR	0x10	/* mcast group membership being deleted */
#define RTM_IFINFO2	0x12	/* */
#define RTM_NEWMADDR2	0x13	/* */
#define RTM_GET2	0x14	/* */

/*
 * Bitmask values for rtm_inits and rmx_locks.
 */
#define RTV_MTU		0x1	/* init or lock _mtu */
#define RTV_HOPCOUNT	0x2	/* init or lock _hopcount */
#define RTV_EXPIRE	0x4	/* init or lock _expire */
#define RTV_RPIPE	0x8	/* init or lock _recvpipe */
#define RTV_SPIPE	0x10	/* init or lock _sendpipe */
#define RTV_SSTHRESH	0x20	/* init or lock _ssthresh */
#define RTV_RTT		0x40	/* init or lock _rtt */
#define RTV_RTTVAR	0x80	/* init or lock _rttvar */

/*
 * Bitmask values for rtm_addrs.
 */
#define RTA_DST		0x1	/* destination sockaddr present */
#define RTA_GATEWAY	0x2	/* gateway sockaddr present */
#define RTA_NETMASK	0x4	/* netmask sockaddr present */
#define RTA_GENMASK	0x8	/* cloning mask sockaddr present */
#define RTA_IFP		0x10	/* interface name sockaddr present */
#define RTA_IFA		0x20	/* interface addr sockaddr present */
#define RTA_AUTHOR	0x40	/* sockaddr for author of redirect */
#define RTA_BRD		0x80	/* for NEWADDR, broadcast or p-p dest addr */

/*
 * Index offsets for sockaddr array for alternate internal encoding.
 */
#define RTAX_DST	0	/* destination sockaddr present */
#define RTAX_GATEWAY	1	/* gateway sockaddr present */
#define RTAX_NETMASK	2	/* netmask sockaddr present */
#define RTAX_GENMASK	3	/* cloning mask sockaddr present */
#define RTAX_IFP	4	/* interface name sockaddr present */
#define RTAX_IFA	5	/* interface addr sockaddr present */
#define RTAX_AUTHOR	6	/* sockaddr for author of redirect */
#define RTAX_BRD	7	/* for NEWADDR, broadcast or p-p dest addr */
#define RTAX_MAX	8	/* size of array to allocate */

struct rt_addrinfo {
    int	rti_addrs;
    struct	sockaddr *rti_info[RTAX_MAX];
};

struct route_cb {
    int	ip_count;
    int	ip6_count;
    int	ipx_count;
    int	ns_count;
    int	iso_count;
    int	any_count;
};



#endif



#define CTL_NET         4               /* network, see socket.h */


#if defined(BSD) || defined(__APPLE__)

#define ROUNDUP(a) \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

char * getdefaultgateway(in_addr_t * addr)
{
#if 0
    /* net.route.0.inet.dump.0.0 ? */
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
        NET_RT_DUMP, 0, 0/*tableid*/};
#endif
    /* net.route.0.inet.flags.gateway */
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
        NET_RT_FLAGS, RTF_GATEWAY};
    size_t l;
    char * buf, * p;
    struct rt_msghdr * rt;
    struct sockaddr * sa;
    struct sockaddr * sa_tab[RTAX_MAX];
    int i;
    int r = -1;
    static char tmp[20];
    
#if TARGET_OS_IPHONE
    if(sysctl(mib, sizeof(mib)/sizeof(int), 0, &l, 0, 0) < 0) {
        return tmp;
    }

    if(l>0) {
        buf = malloc(l);

        if(sysctl(mib, sizeof(mib)/sizeof(int), buf, &l, 0, 0) < 0) {
            return tmp;
        }

        for(p=buf; p<buf+l; p+=rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for(i=0; i<RTAX_MAX; i++) {
                if(rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }
            
            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
               && sa_tab[RTAX_DST]->sa_family == AF_INET
               && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                
                unsigned char octet[4]  = {0,0,0,0};
                for (int i=0; i<4; i++){
                    octet[i] = ( ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr >> (i*8) ) & 0xFF;
                }
                
                if(((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                    
                    *addr = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
                    r = 0;
                    sprintf(tmp,"%d.%d.%d.%d",octet[0],octet[1],octet[2],octet[3]);
                    printf("gateway : %s\n",tmp);
                    printf("gateway address--%d.%d.%d.%d\n",octet[0],octet[1],octet[2],octet[3]);
                }
            }
        }
        free(buf);
    }
    
#endif
    return tmp;
}

#endif
#endif


@implementation MCWiFi

- (instancetype)initWithName:(NSString *)name BSSID:(NSString *)bssid {
    
    if (self = [super init]) {
        
        _wifiName = name;
        _wifiBSSID = bssid;
    }
    return self;
}

@end


#pragma mark -

@implementation MCWiFiManager

- (instancetype)init {
    
    if (self = [super init]) {

    }
    return self;
}

+ (instancetype)defaultInstance {
    static MCWiFiManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


#pragma mark - 
- (void)scanNetworksWithCompletionHandler:(void (^)(NSArray<MCWiFi *> * _Nullable, MCWiFi * _Nullable, NSError * _Nullable))handler {
    
    NSString *wifiName = @"Not Found";
    NSString *wifiBSSID = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        for (int i = 0; i < CFArrayGetCount(myArray); i++) {
            CFStringRef strRef = CFArrayGetValueAtIndex(myArray, i);
            CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(strRef);
            if (myDict != nil) {
                NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
                wifiName = [dict valueForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
                wifiBSSID = [dict valueForKey:(__bridge NSString *)kCNNetworkInfoKeyBSSID];
              
                break;
            }
        }
 
    }
    
    if (myArray) {
        CFRelease(myArray);
    }
    
    
    MCWiFi *wifi = [[MCWiFi alloc] initWithName:wifiName BSSID:wifiBSSID];
    
    if (handler) {
        handler(@[wifi], wifi, nil);
    }
}

- (NSString *)getGatewayIpForCurrentWiFi {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        //*/
        while(temp_addr != NULL) {
            /*/
             int i=255;
             while((i--)>0)
             //*/
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String //ifa_addr
                    //ifa->ifa_dstaddr is the broadcast address, which explains the "255's"
                    //                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];

                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    
#ifndef TARGET_IPHONE_SIMULATOR
    in_addr_t i = inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
    in_addr_t* x = &i;
    unsigned char *s = (unsigned char *)getdefaultgateway(x) ;
    NSString *ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];
    return ip;
#endif
    return nil;
}



- (NSDictionary *)getLocalInfoForCurrentWiFi {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        //*/
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {

                    NSString *broadcast = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    if (broadcast) {
                        [dict setObject:broadcast forKey:@"broadcast"];
                    }
                    NSLog(@"broadcast address--%@",broadcast);

                    NSString *localIp = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    if (localIp) {
                        [dict setObject:localIp forKey:@"localIp"];
                    }
                    
                    NSString *netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                    if (netmask) {
                        [dict setObject:netmask forKey:@"netmask"];
                    }

                    NSString *interface = [NSString stringWithUTF8String:temp_addr->ifa_name];
                    if (interface) {
                        [dict setObject:interface forKey:@"interface"];
                    }
                    return dict;
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return dict;
}
@end


